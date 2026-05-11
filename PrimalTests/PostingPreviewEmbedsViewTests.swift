import XCTest
@testable import Primal

final class PostingPreviewEmbedsViewTests: XCTestCase {

    private func ids(_ media: [PostingAsset]) -> [String] {
        media.map { $0.id }
    }

    func testMoveBeforeOnFirstItemIsGuarded() {
        let media = [PostingAsset(), PostingAsset(), PostingAsset()]
        let result = PostingPreviewEmbedsView.reordered(media, movingIndex: 0, by: -1)
        XCTAssertEqual(ids(result), ids(media))
    }

    func testMoveAfterOnLastItemIsGuarded() {
        let media = [PostingAsset(), PostingAsset(), PostingAsset()]
        let result = PostingPreviewEmbedsView.reordered(media, movingIndex: 2, by: 1)
        XCTAssertEqual(ids(result), ids(media))
    }

    func testMoveBeforeOnMiddleItemSwapsWithPrevious() {
        let media = [PostingAsset(), PostingAsset(), PostingAsset()]
        let result = PostingPreviewEmbedsView.reordered(media, movingIndex: 1, by: -1)
        XCTAssertEqual(ids(result), [media[1].id, media[0].id, media[2].id])
    }

    func testMoveAfterOnFirstItemSwapsWithNext() {
        let media = [PostingAsset(), PostingAsset(), PostingAsset()]
        let result = PostingPreviewEmbedsView.reordered(media, movingIndex: 0, by: 1)
        XCTAssertEqual(ids(result), [media[1].id, media[0].id, media[2].id])
    }

    func testSingleItemArrayHasNoValidMove() {
        let media = [PostingAsset()]
        let movedBefore = PostingPreviewEmbedsView.reordered(media, movingIndex: 0, by: -1)
        let movedAfter = PostingPreviewEmbedsView.reordered(media, movingIndex: 0, by: 1)
        XCTAssertEqual(ids(movedBefore), ids(media))
        XCTAssertEqual(ids(movedAfter), ids(media))
    }

    func testEmptyArrayIsUnchanged() {
        let media: [PostingAsset] = []
        let result = PostingPreviewEmbedsView.reordered(media, movingIndex: 0, by: 1)
        XCTAssertEqual(ids(result), [])
    }

    func testOutOfBoundsIndexIsGuarded() {
        let media = [PostingAsset(), PostingAsset()]
        let result = PostingPreviewEmbedsView.reordered(media, movingIndex: 5, by: -1)
        XCTAssertEqual(ids(result), ids(media))
    }
}
