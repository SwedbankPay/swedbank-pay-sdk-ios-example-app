import XCTest

private let shortTimeout = 20.0
private let defaultTimeout = 60.0
private let paymentCreationTimeout = 120.0
private let completionTimeout = 120.0

private let nonSCACardNumbers = ["4581099940323133", "5226603115488031"]
private let cardNumbers = ["4547781087013329", "4581097032723517", "5226612199533406"] //or 4581099940323133 3d secure: "5226612199533406"
//nonSca that has become sca: "5226600156995650", "5226604266737382", 
//not working: "3569990010082211",
//4547 7810 8701 3329
private let expiryDate = "1230"
private let cvv = "111"
private let retryableActionMaxAttempts = 5
private let ssn = "1997 10202392"    //Ditt personnummer
private let email = "leia.ahlstrom@payex.com" //Din e-post
private let phone = "+46739000001"

/// Note that XCUIElements is never equal to anything, not themselves even
@discardableResult
private func waitForOne(_ elements: [XCUIElement], _ timeout: Double = defaultTimeout,
                        errorMessage: String) throws -> XCUIElement {
    let start = Date()
    while start.timeIntervalSinceNow > -timeout {
        for element in elements where element.waitForExistence(timeout: 1) {
            return element
        }
    }
    throw errorMessage
}

//Quick errors by using strings
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

class Example_app_UITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    private struct NoSCAContinueButtonFound: Error {
        var description: String {
            "Could not find the continue button nor the textfield"
        }
    }
    private var openCartButton: XCUIElement {
        app.buttons.matching(identifier: "viewCartButton").firstMatch
    }
    private var addToCartButton: XCUIElement {
        app.buttons.matching(identifier: "addToCartButton").firstMatch
    }
    private var removeFromCartButton: XCUIElement {
        app.buttons.matching(identifier: "removeFromCartButton").firstMatch
    }
    
    private var externalIntegrationEnvironmentButton: XCUIElement {
        //app.staticTexts.element(matching: .init(format: "label = 'Ext. Integration'"))
        app.buttons["Ext. Integration"]
    }
    private var swedishLanguageButton: XCUIElement {
        app.buttons["Sweden"]
    }
    private var enterpriseEnvironmentButton: XCUIElement {
        //old version needed label matching
        //app.staticTexts.element(matching: .init(format: "label = 'Enterprise (EI)'"))
        //new SwiftUI version uses a simpler format.
        app.buttons["Enterprise (EI)"]
    }
    private var cogButton: XCUIElement {
        app.buttons.matching(identifier: "CogButton").firstMatch
    }
    private var stylingButton: XCUIElement {
        app.buttons.matching(identifier: "Styling").firstMatch
    }
    private var stylingEditor: XCUIElement {
        app.textViews.matching(identifier: "StyleEditor").firstMatch
    }
    
    private var instrumentModeButton: XCUIElement {
        let button = app.buttons["InstrumentModeButton"]
        //app.staticTexts.element(matching: .init(format: "label = 'InstrumentModeButton'"))
        return button
    }
    private var clostInstrumentButton: XCUIElement {
        app.buttons["CloseInstrumentButton"]
    }
    private var consumerButton: XCUIElement {
        app.staticTexts.element(matching: .init(format: "label = 'Consumer'"))
    }
    private var checkinV3Button: XCUIElement {
        app.staticTexts.element(matching: .init(format: "label = 'Checkin V3'"))
    }
    private var toggleUseV2: XCUIElement {
        app.switches.matching(identifier: "toggleUseV2").firstMatch
    }
    private var checkoutButton: XCUIElement {
        app.buttons.matching(identifier: "checkoutButton").firstMatch
    }
    private var errorStyleLabel: XCUIElement {
        app.buttons.matching(identifier: "ErrorStyleLabel").firstMatch
    }
    
    private var completeText: XCUIElement {
        app.staticTexts.element(
            matching: .init(format: "label = 'Payment was successfully completed.'")
        )
    }
    private var completeOrFailureText: XCUIElement {
        app.staticTexts.element(
            matching: NSCompoundPredicate(
                orPredicateWithSubpredicates:
                    [.init(format: "label CONTAINS 'Noe gikk galt'"), .init(format: "label = 'Payment was successfully completed.'")]
                )
        )
    }
    
    private var webView: XCUIElement {
        app.webViews.firstMatch
    }
    
    private func webText(label: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", argumentArray: [label])
        return webView.staticTexts.element(matching: predicate)
    }
    
    private func webTextField(label: String? = nil, contains: String? = nil, identifier: String? = nil) -> XCUIElement {
        
        let predicate: NSPredicate
        if let label {
            predicate = NSPredicate(format: "label = %@", argumentArray: [label])
        } else if let contains {
            predicate = NSPredicate(format: "label CONTAINS[cd] %@", argumentArray: [contains])
        } else if let identifier {
            predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        } else {
            fatalError("Missing argument")
        }
        return webView.textFields.element(matching: predicate)
    }
    
    private func assertZeroOrOne(elements: [XCUIElement]) -> XCUIElement? {
        XCTAssert(elements.count <= 1)
        return elements.first
    }
    private var cardOption: XCUIElement {
        webText(label: "Kort")
    }
    
    private var panInput: XCUIElement {
        let label = "Kortnummer"
        return webText(label: label).exists ? webText(label: label) : webTextField(label: label)
    }
    
    private func expiryInput() throws -> XCUIElement {
        
        try waitForOne([webText(label: "MM/YY"),
                               webTextField(contains: "Gyldig til MM/ÅÅ"),
                               webText(label: "MM/ÅÅ"),
                               webTextField(label: "expiryInput"),
                               webTextField(identifier: "expiryInput"),
                           webTextField(contains: "Expiry date MM/YY")],
                              errorMessage: "Could not find expiry input (MM/YY")
    }
    
    private func cvvInput() throws -> XCUIElement {
        
        try waitForOne([webTextField(label: "cvcInput"), webTextField(label: "cccvc"),
                               webText(label: "CVV"),
                               webTextField(label: "CVV"),
                        webTextField(label: "CVC"),
                               webTextField(identifier: "cvcInput-1"),
                               webTextField(contains: "cccvc"),
                              ],
                              errorMessage: "CVV input not found!")
    }
    
    private var payButton: XCUIElement {
        webView.buttons.element(matching: .init(format: "label BEGINSWITH 'Betal '"))
    }
    private var continueButton: XCUIElement {
        webView.buttons.element(matching: .init(format: "label = 'Continue'"))
    }
    private var confirmButton: XCUIElement {
        webView.buttons.element(matching: .init(format: "label = 'Confirm'"))
    }
    
    //The new 3DS page
    private var otpTextField: XCUIElement {
        webView.textFields.firstMatch
    }
    private var keyboardDoneButton: XCUIElement {
        app.buttons.element(matching: .init(format: "label = 'Done'"))
    }
    
    private func input(to webElement: XCUIElement, text: String) {
        webElement.tap()
        webView.typeText(text)
        keyboardDoneButton.tap()
    }
    
    private func assertAndTap(_ button: XCUIElement, _ message: String) throws {
        waitAndAssertExists(button, message)
        button.tap()
    }
    
    override func setUp() {
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
    }
    
    func performPayment(_ cardNumber: String) throws {
        
        waitAndAssertExists(timeout: shortTimeout, cardOption, "Card option not found")
        
        XCTAssert(tapCardOptionAndWaitForPanInput(), "PAN input not found")
        input(to: panInput, text: cardNumber)
        
        let expiryInput = try expiryInput()
        input(to: expiryInput, text: expiryDate)
        
        let cvvInput = try cvvInput()
        input(to: cvvInput, text: cvv)
        
        waitAndAssertExists(payButton, "Pay button not found")
        payButton.tap()
        
        
    }
    
    func scaAproveCard() throws {
        
        if continueButton.waitForExistence(timeout: shortTimeout) {
            continueButton.tap()
        } else if otpTextField.waitForExistence(timeout: shortTimeout) {
            //whitelistThisMerchant.tap() it also does not matter!
            input(to: otpTextField, text: "1234")
            
        } else {
            throw NoSCAContinueButtonFound()
        }
    }
    
    //Testing regular purchase within enteprise
    func testCardPayment() throws {
        
        try openBasket()
        
        waitAndAssertExists(enterpriseEnvironmentButton, "Environment button not found")
        enterpriseEnvironmentButton.tap()
        
        try makePurchase()
    }
    
    func makePurchase() throws {
        
        XCTAssert(checkoutButton.exists, "Checkout button not found")
        checkoutButton.tap()
        
        waitAndAssertExists(webView, "Web view not found")
        
        for cardNumber in cardNumbers {
            try performPayment(cardNumber)
            try scaAproveCard()
            if completeOrFailureText.waitForExistence(timeout: shortTimeout) {
                if completeText.exists {
                    break
                }
            }
            startOver()
        }
        
        waitAndAssertExists(timeout: completionTimeout, completeText, "Payment did not complete")
    }
    
    func testInstrumentMode() throws {
        
        try openBasket()
        
        try assertAndTap(cogButton, "No cog button")
        
        app.swipeUp()
        try assertAndTap(instrumentModeButton, "Could not find instrument mode button")
        let picker = app.pickers["InstrumentPicker"]
        waitAndAssertExists(picker, "No picker found")
        app.pickerWheels.element.adjust(toPickerWheelValue: "CreditCard")
        try assertAndTap(clostInstrumentButton, "No close button found")
        app.swipeDown()
        try assertAndTap(checkoutButton, "No ckechout button found")
        
        _ = waitForPanInput(true)
        waitAndAssertExists(timeout: 2, panInput, "No pan input found, we are not in instrument mode")
    }
    
    /// MonthlyPayment uses bankID, so a good way to test your app-links. It requires V2, and is active on the Ext. int merchant and
    func manualOnlytestV2MonthlyPayment() throws {
        
        try openBasket()
        
        try assertAndTap(cogButton, "No cog button")
        
        try assertAndTap(swedishLanguageButton, "language can't be found")
        try assertAndTap(externalIntegrationEnvironmentButton, "Ext. int button can't be found")
        
        app.swipeUp()
        
        try assertAndTap(toggleUseV2, "Could not find V2 mode toggle")
        if (toggleUseV2.value as? String ?? "0") == "0" {
            toggleUseV2.twoFingerTap()
        }
        XCTAssertFalse(toggleUseV2.value as? String ?? "0" == "0", "Could not set V2 toggle")
        
        app.swipeDown()
        try assertAndTap(checkoutButton, "No ckechout button found")
        
        XCTAssertTrue(webText(label: "Månadsfaktura").waitForExistence(timeout: defaultTimeout))
        webText(label: "Månadsfaktura").tap()
        
        // uncomment to wait forever here while testing, we can't automate bankID testing yet...
        _ = toggleUseV2.waitForExistence(timeout: completionTimeout * 9871)
    }
    
    private var ssnTextField: XCUIElement {
        webView.textFields.element(matching: .init(format: "label CONTAINS[cd] 'Fødselsnummer'"))
    }
    private var prefilledCard: XCUIElement {
        webView.staticTexts.element(matching: .init(format: "label CONTAINS[cd] '••••'"))
    }
    private var agreeButton: XCUIElement {
        webView.buttons.element(matching: .init(format: "label CONTAINS[cd] 'Lagre'"))
    }
    
    func testPayerReference() throws {
        
        try openBasket()
        
        try assertAndTap(cogButton, "No cog button")
        try assertAndTap(externalIntegrationEnvironmentButton, "No ext. Integration")
        app.swipeUp()
        
        //setup a new user
        let generateToken = app.buttons["GeneratePaymentTokenToggle"]
        try assertAndTap(generateToken, "No generate token toggle")
        try assertAndTap(app.buttons["GeneratePayerRef"], "No generate ref button")
        
        //make a purchase as this customer
        app.swipeDown()
        XCTAssert(checkoutButton.exists, "Checkout button not found")
        checkoutButton.tap()
        waitAndAssertExists(webView, "Web view not found")
        
        try performPayment(nonSCACardNumbers.first!)
        waitAndAssertExists(completeText, "Purchase failed")
        try assertAndTap(keyboardDoneButton, "no Done button after purchase")
        
        //Go back and make a new purchase with the same payer ref and fetching the token
        try openBasket()
        app.swipeUp()
        try assertAndTap(generateToken, "No generate token toggle")
        
        //fetch token
        try assertAndTap(app.buttons["ShowGetTokenScreen"], "No generate token toggle")
        try assertAndTap(app.buttons["FetchTokenButton"], "No generate token toggle")
        try assertAndTap(app.buttons["UseTokenButton"], "No use token button")
        
        //close and make a new purchase
        app.swipeDown()
        XCTAssert(checkoutButton.exists, "Checkout button not found")
        checkoutButton.tap()
        waitAndAssertExists(webView, "Web view not found")
        
        //Now there should only be a pay button
        try assertAndTap(payButton, "Pay button not found")
        while payButton.waitForExistence(timeout: 5) {
            //if tapped too early things won't work
            payButton.tap()
        }
        waitAndAssertExists(completeText, "Purchase failed")
    }
    
    func testStyling() throws {
        
        try openBasket()
        app.swipeUp()
        
        try assertAndTap(stylingButton, "No stylingButton")
        try assertAndTap(stylingEditor, "No styling editor")
        stylingEditor.typeText("""
        { "body": { "background-color" : "red" }}
        """)
        if errorStyleLabel.waitForExistence(timeout: 1) {
            XCTFail("Styling shows error, but has a valid JSON")
        }
    }
    
    private func openBasket() throws {
        
        waitAndAssertExists(addToCartButton, "Add to cart button not found")
        addToCartButton.tap()
        waitAndAssertExists(removeFromCartButton, "Remove from cart button not found")
        
        XCTAssert(openCartButton.exists, "View cart button not found")
        openCartButton.tap()
    }
    
    private func startOver() {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()
        
        _ = openCartButton.waitForExistence(timeout: shortTimeout)
        openCartButton.tap()
        
        _ = openCartButton.waitForExistence(timeout: shortTimeout)
        checkoutButton.tap()
        waitAndAssertExists(webView, "Web view not found")
    }
    
    private func waitAndAssertExists(
        timeout: Double = defaultTimeout,
        _ element: XCUIElement,
        _ message: String
    ) {
        return XCTAssert(element.waitForExistence(timeout: timeout), message)
    }
    
    private func tapCardOptionAndWaitForPanInput() -> Bool {
        for _ in 0..<50 {
            cardOption.tap()
            if waitForPanInput() {
                return true
            }
        }
        return false
    }
    
    private func waitForPanInput(_ loop: Bool = false) -> Bool {
        if loop {
            for _ in 0..<50 {
                if panInput.waitForExistence(timeout: 5) {
                    return true
                }
            }
        }
        return panInput.waitForExistence(timeout: 5)
    }
}
