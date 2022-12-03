//
//  ViewController.swift
//  CustomSlider
//
//  Created by Huy Vuong on 03/12/2022.
//

import UIKit

class ViewController: UIViewController, CustomSliderDelegate {

    // MARK: - IBOutlet
    @IBOutlet private weak var sliderCustomView: CustomSlider!
    
    let sliderValueArray: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

    // MARK: - Init:
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderCustomView.setNumberOfSegments(sliderValueArray.count, minText: sliderValueArray.first, maxText: sliderValueArray.last)
        sliderCustomView.shouldSliderButtonOverlap = true
        sliderCustomView.delegate = self
        sliderCustomView.scrollStartSlider(to: 1, andEnd: 6)
    }

    // MARK: - TPCustomSliderDelegate
    func sliderScrolled(_ slider: CustomSlider?, toMinIndex minIndex: Int, andMaxIndex maxIndex: Int, endDragDrop: Bool) {
        sliderCustomView.minRangeText = sliderValueArray[minIndex]
        sliderCustomView.maxRangeText = sliderValueArray[maxIndex]
    }
}
