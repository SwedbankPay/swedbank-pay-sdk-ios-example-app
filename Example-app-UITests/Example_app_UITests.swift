import XCTest

private let defaultTimeout = 60.0
private let paymentCreationTimeout = 300.0
private let completionTimeout = 300.0

private let cardNumber = "4581097032723517" //or 4581099940323133 3d secure: "5226612199533406"
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
    
    private var webView: XCUIElement {
        app.webViews.firstMatch
    }
    private func webText(label: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label = %@", argumentArray: [label])
        return webView.staticTexts.element(matching: predicate)
    }
    private func assertZeroOrOne(elements: [XCUIElement]) -> XCUIElement? {
        XCTAssert(elements.count <= 1)
        return elements.first
    }
    private var cardOption: XCUIElement {
        webText(label: "Kort")
    }
    private var panInput: XCUIElement {
        webText(label: "Kortnummer")
    }
    private var expiryInput: XCUIElement {
        webText(label: "MM/ÅÅ")
    }
    private var cvvInput: XCUIElement {
        webText(label: "CVC")
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
    
    func testV3Payment() throws {
        waitAndAssertExists(addToCartButton, "Add to cart button not found")
        addToCartButton.tap()
        XCTAssert(openCartButton.exists, "View card button not found")
        openCartButton.tap()
        
        app.swipeUp()
        waitAndAssertExists(consumerButton, "Consumer button not found")
        consumerButton.tap()
        
        waitAndAssertExists(externalIntegrationEnvironmentButton, "Environment button not found")
        externalIntegrationEnvironmentButton.tap()
        /*
        app.swipeUp()
        waitAndAssertExists(checkinV3Button, "Checkin V3 button not found")
        checkinV3Button.tap()
         */
        
        waitAndAssertExists(webView, "Web view not found")
        
        try performPayment()
        
        //while building..
        waitAndAssertExists(timeout: 900000000, completeText, "Payment did not complete")
    }
    
    func performPayment() throws {
        
        waitAndAssertExists(timeout: paymentCreationTimeout, cardOption, "Card option not found")
        
        XCTAssert(tapCardOptionAndWaitForPanInput(), "PAN input not found")
        input(to: panInput, text: cardNumber)
        
        waitAndAssertExists(expiryInput, "Expiry date input not found")
        input(to: expiryInput, text: expiryDate)
        
        waitAndAssertExists(cvvInput, "CVV input not found")
        input(to: cvvInput, text: cvv)
        
        waitAndAssertExists(payButton, "Pay button not found")
        payButton.tap()
    }
    
    func testV2CardPayment() throws {
        waitAndAssertExists(addToCartButton, "Add to cart button not found")
        addToCartButton.tap()
        waitAndAssertExists(removeFromCartButton, "Remove from cart button not found")
        
        XCTAssert(openCartButton.exists, "View card button not found")
        openCartButton.tap()
        
        waitAndAssertExists(externalIntegrationEnvironmentButton, "Environment button not found")
        externalIntegrationEnvironmentButton.tap()
        
        XCTAssert(checkoutButton.exists, "Checkout button not found")
        checkoutButton.tap()
        
        waitAndAssertExists(webView, "Web view not found")
        
        waitAndAssertExists(timeout: paymentCreationTimeout, cardOption, "Card option not found")
        
        XCTAssert(tapCardOptionAndWaitForPanInput(), "PAN input not found")
        input(to: panInput, text: cardNumber)
        
        waitAndAssertExists(expiryInput, "Expiry date input not found")
        input(to: expiryInput, text: expiryDate)
        
        waitAndAssertExists(cvvInput, "CVV input not found")
        input(to: cvvInput, text: cvv)
        
        waitAndAssertExists(payButton, "Pay button not found")
        payButton.tap()
        
        waitAndAssertExists(timeout: completionTimeout, completeText, "Payment did not complete")
    }
    
    private func waitAndAssertExists(
        timeout: Double = defaultTimeout,
        _ element: XCUIElement,
        _ message: String
    ) {
        return XCTAssert(element.waitForExistence(timeout: timeout), message)
    }
    
    private func tapCardOptionAndWaitForPanInput() -> Bool {
        for _ in 0..<5 {
            cardOption.tap()
            if panInput.waitForExistence(timeout: defaultTimeout) {
                return true
            }
        }
        return false
    }
}
