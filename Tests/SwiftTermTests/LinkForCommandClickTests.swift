#if os(macOS)
import AppKit
import Testing
@testable import SwiftTerm

/// `linkForCommandClick(at:)` answers what a Command-click at a point would open, so a host can
/// say where a link goes, or offer a menu for it, before it's clicked.
@MainActor
struct LinkForCommandClickTests {
    private func view(showing text: String) async -> TerminalView {
        let view = TerminalView(frame: NSRect(x: 0, y: 0, width: 640, height: 200))
        view.feed(text: text)
        for _ in 0..<200 where view.terminalStateSnapshot().visibleRows.first?.text.isEmpty != false {
            try? await Task.sleep(for: .milliseconds(10))
        }
        return view
    }

    /// The middle of the cell at `col` on the top row.
    private func point(col: Int, row: Int = 0, in view: TerminalView) -> CGPoint {
        CGPoint(x: view.cellDimension.width * (CGFloat(col) + 0.5), y: view.bounds.maxY - view.cellDimension.height * (CGFloat(row) + 0.5))
    }

    @Test func findsALinkInTheText() async {
        let view = await view(showing: "see https://example.com/a for more")
        #expect(view.linkForCommandClick(at: point(col: 8, in: view)) == "https://example.com/a")
        #expect(view.linkForCommandClick(at: point(col: 1, in: view)) == nil, "off the link")
        #expect(view.linkForCommandClick(at: point(col: 8, row: 3, in: view)) == nil, "a blank row")
    }

    @Test func givesAHyperlinksAddressNotItsText() async {
        let view = await view(showing: "\u{1b}]8;;https://example.com/pr/12\u{07}#12\u{1b}]8;;\u{07} merged")
        #expect(view.linkForCommandClick(at: point(col: 1, in: view)) == "https://example.com/pr/12")
    }
}
#endif
