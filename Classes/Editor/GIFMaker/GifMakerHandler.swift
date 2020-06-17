//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

typealias MediaFrame = (image: UIImage, interval: TimeInterval)

protocol GifMakerHandlerDelegate: class {
    func didConfirmGif()

    func getDefaultTimeIntervalForImageSegments() -> TimeInterval

    func setThumbnails(count: Int)
}

class GifMakerHandler {

    weak var delegate: GifMakerHandlerDelegate?

    var segments: [CameraSegment]?

    var shouldExport: Bool {
        return frames != nil
    }

    private let player: MediaPlayer

    private var frames: [MediaFrame]? {
        didSet {
            guard let frames = frames else {
                delegate?.setThumbnails(count: 0)
                segments = nil
                return
            }

            delegate?.setThumbnails(count: frames.count)
            segments = frames.map { frame in
                CameraSegment.image(frame.image, nil, frame.interval, .init(source: .kanvas_camera))
            }
        }
    }

    private var previousTrim: ClosedRange<CGFloat>?

    init(player: MediaPlayer) {
        self.player = player
    }

    func load(segments: [CameraSegment], completion: @escaping () -> Void) {
        if frames != nil {
            completion()
        }
        else {
            let defaultInterval = delegate?.getDefaultTimeIntervalForImageSegments() ?? 1.0/6.0
            loadFrames(from: segments, defaultInterval: defaultInterval) { frames in
                self.frames = frames
                completion()
            }
        }
    }

    private func loadFrames(from segments: [CameraSegment], defaultInterval: TimeInterval, completion: @escaping ([MediaFrame]) -> ()) {
        let group = DispatchGroup()
        var frames: [Int: [GIFDecodeFrame]] = [:]
        let encoder = GIFEncoderImageIO()
        let decoder = GIFDecoderFactory.create(type: .imageIO)
        for (i, segment) in segments.enumerated() {
            if let cgImage = segment.image?.cgImage {
                frames[i] = [(image: cgImage, interval: segment.timeInterval ?? defaultInterval)]
            }
            else if let videoURL = segment.videoURL {
                group.enter()
                encoder.encode(video: videoURL, loopCount: 0, framesPerSecond: 10) { gifURL in
                    guard let gifURL = gifURL else {
                        group.leave()
                        return
                    }
                    decoder.decode(image: gifURL) { gifFrames in
                        frames[i] = gifFrames
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            let orderedFrames = frames.keys.sorted().reduce([]) { (partialOrderedFrames, index) in
                return partialOrderedFrames + (frames[index] ?? [])
            }
            let mediaFrames = orderedFrames.map { (image: UIImage(cgImage: $0.image), interval: $0.interval) }
            completion(mediaFrames)
        }
    }
}

extension GifMakerHandler : GifMakerControllerDelegate {

    func didConfirmGif() {
        delegate?.didConfirmGif()
    }

    func didStartTrimming() {
        previousTrim = 0.0...100.0
    }

    func didTrim(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        guard let previousTrim = previousTrim else {
            return
        }
        if previousTrim.lowerBound != startingPercentage {
            player.playSingleFrame(at: startingPercentage / 100.0)
        }
        else if previousTrim.upperBound != endingPercentage {
            player.playSingleFrame(at: endingPercentage / 100.0)
        }
        self.previousTrim = startingPercentage...endingPercentage
    }

    func didEndTrimming(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        guard let segments = segments else {
            return
        }
        previousTrim = nil
        let startLocation = startingPercentage / 100.0
        var startIndex = Int(CGFloat(segments.count) * startLocation)
        if startIndex < 0 {
            startIndex = 0
        }
        player.startMediaIndex = startIndex

        let endLocation = endingPercentage / 100.0
        var endIndex = Int(CGFloat(segments.count) * endLocation)
        if endIndex > segments.count - 1 {
            endIndex = segments.count - 1
        }
        player.endMediaIndex = endIndex

        player.cancelPlayingSingleFrame()
    }

    func getThumbnail(at index: Int) -> UIImage? {
        return player.getFrame(at: index)
    }

    func didSelectSpeed(_ speed: Float) {
        player.rate = speed
    }

    func didSelectPlayback(_ option: PlaybackOption) {
        player.playbackMode = MediaPlayerPlaybackMode(from: option)
    }
}
