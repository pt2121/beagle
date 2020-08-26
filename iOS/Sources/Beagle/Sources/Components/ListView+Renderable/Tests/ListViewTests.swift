/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest
@testable import Beagle
import SnapshotTesting
import BeagleSchema

final class ListViewTests: XCTestCase {

    private let imageSize = ImageSize.custom(CGSize(width: 300, height: 300))

    private let just3Rows: [ServerDrivenComponent] = [
        Text("Item 1", widgetProperties: .init(style: .init(backgroundColor: "#FF0000"))),
        Text("Item 2", widgetProperties: .init(style: .init(backgroundColor: "#00FF00"))),
        Text("Item 3", widgetProperties: .init(style: .init(backgroundColor: "#0000FF")))
    ]
    
    private let manyRows: [ServerDrivenComponent] = (0..<20).map { i in
        return ListViewTests.createText("Item \(i)", position: Double(i) / 19)
    }
    
    private let manyLargeRows: [ServerDrivenComponent] = (0..<20).map { i in
        return ListViewTests.createText(
            "< \(i) \(String(repeating: "-", count: 22)) \(i) >",
            position: Double(i) / 19
        )
    }
    
    private let rowsWithDifferentSizes: [ServerDrivenComponent] = (0..<20).map { i in
        return ListViewTests.createText(
            "< \(i) ---\(i % 3 == 0 ? "/↩\n↩\n /" : "")--- \(i) >",
            position: Double(i) / 19
        )
    }
    
    private lazy var controller = BeagleScreenViewController(ComponentDummy())
    
    private func renderListView(_ listComponent: ListView) -> UIView {
        let renderer = BeagleRenderer(controller: controller)
        let view = renderer.render(listComponent)
        controller.configBindings()
        return view
    }
    
    func createListView(
        valueContext: DynamicObject,
        direction: ListView.Direction
    ) -> ListView {
        return ListView(
            context: Context(
                id: "initialContext",
                value: valueContext
            ),
            dataSource: Expression("@{initialContext}"),
            direction: direction,
            template: Container(
                children: [
                    Text(
                        "@{item}",
                        widgetProperties: WidgetProperties(
                            style: Style(
                                backgroundColor: "#bfdcae"
                            )
                        )
                    )
                ],
                widgetProperties: WidgetProperties(
                    style: Style(
                        backgroundColor: "#81b214",
                        margin: EdgeValue().all(10)
                    )
                )
            ),
            widgetProperties: WidgetProperties(
                style: Style(
                    backgroundColor: "#206a5d",
                    flex: Flex().grow(1)
                )
            )
        )
    }
    
// MARK: - Testing Direction
    
    let simpleContext: DynamicObject = ["L", "I", "S", "T", "V", "I", "E", "W"]
    
    func testHorizontalDirection() {
        let component = createListView(
            valueContext: simpleContext,
            direction: .horizontal
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }
    
    func testVerticalDirection() {
          let component = createListView(
              valueContext: simpleContext,
              direction: .vertical
          )

          let view = renderListView(component)

          assertSnapshotImage(view, size: imageSize)
      }
    
    // MARK: - Testing Context With Different Sizes
    
    let contextDifferentSizes: DynamicObject = ["LIST", "VIEW", "1", "LIST VIEW", "TEST 1", "TEST LIST VIEW", "12345"]
    
    func testHorizontalDirectionWithDifferentSizes() {
         let component = createListView(
             valueContext: contextDifferentSizes,
             direction: .horizontal
         )

         let view = renderListView(component)

         assertSnapshotImage(view, size: imageSize)
     }
     
     func testVerticalDirectionWithDifferentSizes() {
           let component = createListView(
               valueContext: contextDifferentSizes,
               direction: .vertical
           )

           let view = renderListView(component)

           assertSnapshotImage(view, size: imageSize)
       }
    
    // MARK: - Testing Execute Action onScrollEnd

    func createListViewWithAction(
        direction: ListView.Direction,
        action: Action
    ) -> ListView {
        return ListView(
            context: Context(
                id: "initialContext",
                value: ["Test"]
            ),
            dataSource: Expression("@{initialContext}"),
            direction: direction,
            template: Container(
                children: [
                    Text(
                        "@{item}",
                        widgetProperties: WidgetProperties(
                            style: Style(
                                backgroundColor: "#bfdcae"
                            )
                        )
                    )
                ],
                widgetProperties: WidgetProperties(
                    style: Style(
                        backgroundColor: "#81b214",
                        margin: EdgeValue().all(10)
                    )
                )
            ),
            onScrollEnd: [action],
            widgetProperties: WidgetProperties(
                style: Style(
                    backgroundColor: "#206a5d",
                    flex: Flex().grow(1)
                )
            )
        )
    }
    
    func testVerticalWithAction() {
        
        let expectation = XCTestExpectation(description: "Execute onScrollEnd")
        
        let action = CustomAction(expectation: expectation)
        
        let component = createListViewWithAction(
            direction: .vertical,
            action: action
        )
        
        let view = renderListView(component) as? ListViewUIComponent
        view?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        view?.layoutIfNeeded()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(view?.onScrollEndExecuted, true)
    }

    func testHorizontalWithAction() {
        
        let expectation = XCTestExpectation(description: "Execute onScrollEnd")
        
        let action = CustomAction(expectation: expectation)
        
        let component = createListViewWithAction(
            direction: .horizontal,
            action: action
        )
        
        let view = renderListView(component) as? ListViewUIComponent
        view?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        view?.layoutIfNeeded()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(view?.onScrollEndExecuted, true)
    }
}

struct CustomAction: Action {
    
    let verify = false
    let expectation: XCTestExpectation
    
    init(from decoder: Decoder) throws {
        fatalError("Not implemented!")
    }
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func execute(controller: BeagleController, origin: UIView) {
        expectation.fulfill()
    }
    
}

// MARK: - Testing Helpers

private class ComponentWithRequestViewSpy: UIView, HTTPRequestCanceling {

    private(set) var cancelHTTPRequestCalled = false
    
    func cancelHTTPRequest() {
        cancelHTTPRequestCalled = true
    }

}

// MARK: - Tests deprecated
extension ListViewTests {
    
    func testDirectionHorizontal() throws {
        let component = ListView(
            children: just3Rows,
            direction: .horizontal
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }

    func testDirectionVertical() throws {
        let component = ListView(
            children: just3Rows,
            direction: .vertical
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }

    // MARK: - Many Rows

    func testDirectionHorizontalWithManyRows() {
        let component = ListView(
            children: manyRows,
            direction: .horizontal
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }

    func testDirectionVerticalWithManyRows() {
        let component = ListView(
            children: manyRows,
            direction: .vertical
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }

    // MARK: - Many Large Rows

    func testDirectionHorizontalWithManyLargeRows() {
        let component = ListView(
            children: manyLargeRows,
            direction: .horizontal
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }

    func testDirectionVerticalWithManyLargeRows() {
        let component = ListView(
            children: manyLargeRows,
            direction: .vertical
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }

    // MARK: Rows with Different Sizes

    func testDirectionHorizontalWithRowsWithDifferentSizes() {
        let component = ListView(
            children: rowsWithDifferentSizes,
            direction: .horizontal
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }

    func testDirectionVerticalWithRowsWithDifferentSizes() {
        let component = ListView(
            children: rowsWithDifferentSizes,
            direction: .vertical
        )

        let view = renderListView(component)

        assertSnapshotImage(view, size: imageSize)
    }
    
    // MARK: - Helper

    private static func createText(_ string: String, position: Double) -> Text {
        let text = Int(round(position * 255))
        let textColor = "#\(String(repeating: String(format: "%02X", text), count: 3))"
        let background = 255 - text
        let backgroundColor = "#\(String(repeating: String(format: "%02X", background), count: 3))"
        return Text(
            .value(string),
            textColor: .value(textColor),
            widgetProperties: .init(style: Style(backgroundColor: backgroundColor))
        )
    }
}
