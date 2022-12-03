# CustomSlider
CustomSlider is a custom implementation of a slider, similar to UISlider, for predefined values

![](screenshots/example.mp4)

## Usage

 ```swift
 // MARK: - IBOutlet

 @IBOutlet private weak var sliderCustomView: CustomSlider!
 // MARK: - Init:

 let sliderValueArray: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
 sliderCustomView.setNumberOfSegments(sliderValueArray.count, minText: sliderValueArray.first, maxText: sliderValueArray.last)
 sliderCustomView.shouldSliderButtonOverlap = true
 sliderCustomView.delegate = self
 sliderCustomView.scrollStartSlider(to: 1, andEnd: 6)

 // MARK: - TPCustomSliderDelegate
 func sliderScrolled(_ slider: TPCustomSlider?, toMinIndex minIndex: Int, andMaxIndex maxIndex: Int, endDragDrop: Bool) {
    sliderCustomView.minRangeText = sliderValueArray[minIndex]
    sliderCustomView.maxRangeText = sliderValueArray[maxIndex]
 }
 ```
## License
CustomSlider is available under the MIT license. See the LICENSE file for more info.
