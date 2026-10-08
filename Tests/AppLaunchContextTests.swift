import AppKit
import Carbon.HIToolbox
import XCTest
@testable import OnePointer

@MainActor
final class AppLaunchContextTests: XCTestCase {
    func testManualLaunchShowsSettings() {
        XCTAssertTrue(AppLaunchContext.shouldShowSettings(event: nil, arguments: ["OnePointer"]))
        XCTAssertTrue(AppLaunchContext.shouldShowSettings(event: openEvent(), arguments: ["OnePointer"]))
    }

    func testExplicitBackgroundLaunchDoesNotShowSettings() {
        XCTAssertFalse(AppLaunchContext.shouldShowSettings(event: nil, arguments: ["OnePointer", "--background"]))
    }

    func testLoginAndServiceLaunchDoNotShowSettings() {
        for reason in [keyAELaunchedAsLogInItem, keyAELaunchedAsServiceItem] {
            let event = openEvent()
            event.setParam(NSAppleEventDescriptor(enumCode: reason), forKeyword: keyAEPropData)
            XCTAssertFalse(AppLaunchContext.shouldShowSettings(event: event, arguments: ["OnePointer"]))
        }
    }

    func testUnrelatedEventDoesNotSuppressManualLaunch() {
        let event = NSAppleEventDescriptor(
            eventClass: kCoreEventClass,
            eventID: kAEReopenApplication,
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        event.setParam(NSAppleEventDescriptor(enumCode: keyAELaunchedAsLogInItem), forKeyword: keyAEPropData)
        XCTAssertTrue(AppLaunchContext.shouldShowSettings(event: event, arguments: ["OnePointer"]))
    }

    private func openEvent() -> NSAppleEventDescriptor {
        NSAppleEventDescriptor(
            eventClass: kCoreEventClass,
            eventID: kAEOpenApplication,
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
    }
}
