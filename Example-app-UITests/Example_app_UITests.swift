import XCTest

private let shortTimeout = 20.0
private let defaultTimeout = 60.0
private let paymentCreationTimeout = 120.0
private let completionTimeout = 120.0

private let cardNumbers = ["5226604266737382", "5226603115488031", "5226600156995650", "4581097032723517"] //or 4581099940323133 3d secure: "5226612199533406"
//not working: "3569990010082211",

private let expiryDate = "1230"
private let cvv = "111"

class Example_app_UITests: XCTestCase {
    
    private var app: XCUIApplication!
    
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
        app.staticTexts.element(matching: .init(format: "label = 'Ext. Integration'"))
    }
    private var enterpriseEnvironmentButton: XCUIElement {
        app.staticTexts.element(matching: .init(format: "label = 'Enterprise (EI)'"))
    }
    private var cogButton: XCUIElement {
        app.buttons.matching(identifier: "CogButton").firstMatch
    }
    private var instrumentModeButton: XCUIElement {
        let button = XCUIApplication().buttons["InstrumentModeButton"]
        //app.staticTexts.element(matching: .init(format: "label = 'InstrumentModeButton'"))
        return button
    }
    private var consumerButton: XCUIElement {
        app.staticTexts.element(matching: .init(format: "label = 'Consumer'"))
    }
    private var checkinV3Button: XCUIElement {
        app.staticTexts.element(matching: .init(format: "label = 'Checkin V3'"))
    }
    private var checkoutButton: XCUIElement {
        app.buttons.matching(identifier: "checkoutButton").firstMatch
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
    private func webTextField(label: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", argumentArray: [label])
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
        let input = webText(label: label).exists ? webText(label: label) : webTextField(label: label)
        return input
    }
    
    private var expiryInput: XCUIElement {
        
        let label = "MM/ÅÅ"
        let input = webText(label: label).exists ? webText(label: label) : webTextField(label: "Gyldig til MM/ÅÅ")
        return input
    }
    private var cvvInput: XCUIElement {
        var label = "CVC"
        var input = webText(label: label)
        if input.exists { return input }
        input = webTextField(label: label)
        if input.exists { return input }
        
        label = "CVV"
        input = webText(label: label)
        if input.exists { return input }
        input = webTextField(label: label)
        
        return input
    }
    private var payButton: XCUIElement {
        webView.buttons.element(matching: .init(format: "label BEGINSWITH 'Betal '"))
    }
    
    private var keyboardDoneButton: XCUIElement {
        app.buttons.element(matching: .init(format: "label = 'Done'"))
    }
    
    private func input(to webElement: XCUIElement, text: String) {
        webElement.tap()
        webView.typeText(text)
        keyboardDoneButton.tap()
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
        
        waitAndAssertExists(expiryInput, "Expiry date input not found")
        input(to: expiryInput, text: expiryDate)
        
        waitAndAssertExists(cvvInput, "CVV input not found")
        input(to: cvvInput, text: cvv)
        
        waitAndAssertExists(payButton, "Pay button not found")
        payButton.tap()
    }
    
    func testCardPayment() throws {
        
        waitAndAssertExists(addToCartButton, "Add to cart button not found")
        addToCartButton.tap()
        waitAndAssertExists(removeFromCartButton, "Remove from cart button not found")
        
        XCTAssert(openCartButton.exists, "View card button not found")
        openCartButton.tap()
        
        waitAndAssertExists(enterpriseEnvironmentButton, "Environment button not found")
        enterpriseEnvironmentButton.tap()
        
        XCTAssert(checkoutButton.exists, "Checkout button not found")
        checkoutButton.tap()
        
        waitAndAssertExists(webView, "Web view not found")
        
        for cardNumber in cardNumbers {
            try performPayment(cardNumber)
            if completeOrFailureText.waitForExistence(timeout: shortTimeout) {
                if completeText.exists {
                    break
                }
            }
            startOver()
        }
        
        waitAndAssertExists(timeout: completionTimeout, completeText, "Payment did not complete")
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
            if panInput.waitForExistence(timeout: 5) {
                return true
            }
        }
        return false
    }
}
