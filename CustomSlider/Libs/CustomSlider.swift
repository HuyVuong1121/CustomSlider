//
//  CustomSlider.swift
//  CustomSlider
//
//  Created by Huy Vuong on 03/12/2022.
//

import Foundation
import UIKit

protocol CustomSliderDelegate: AnyObject {
    func sliderScrolled(_ slider: CustomSlider?, toMinIndex minIndex: Int, andMaxIndex maxIndex: Int, endDragDrop: Bool)
}

///
/// ```swift
/// // MARK: - IBOutlet
///
/// @IBOutlet private weak var sliderCustomView: CustomSlider!
/// // MARK: - Init:
///
/// let sliderValueArray: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
/// sliderCustomView.setNumberOfSegments(sliderValueArray.count, minText: sliderValueArray.first, maxText: sliderValueArray.last)
/// sliderCustomView.shouldSliderButtonOverlap = true
/// sliderCustomView.delegate = self
/// sliderCustomView.scrollStartSlider(to: 1, andEnd: 6) // index Slider start at 1.
///
/// // MARK: - TPCustomSliderDelegate
/// func sliderScrolled(_ slider: TPCustomSlider?, toMinIndex minIndex: Int, andMaxIndex maxIndex: Int, endDragDrop: Bool) {
///    sliderCustomView.minRangeText = sliderValueArray[minIndex]
///    sliderCustomView.maxRangeText = sliderValueArray[maxIndex]
/// }
/// ```
///
class CustomSlider: UIView {
    
    // PUBLIC variable
    // The number of points in slider
    public var numberOfSegments: Int = 0
    
    // This value should be set if slider button should overlap or not. Default to NO. ie., 1 segment space will be present between the sliders.
    public var shouldSliderButtonOverlap: Bool = false
    
    // The color that is used for rangeSlider unselected range view. (i.e., the view that is not within the slider points). Default is gray.
    public var rangeSliderBackgroundColor: UIColor = .gray
    
    // The color that is used for rangeSlider selected range view. (i.e., the view that is between the slider points). Default is orange.
    public var rangeSliderForegroundColor: UIColor = .orange
    
    // The label color to be used for min range display. Default is white.
    public var rangeDisplayLabelColor: UIColor = .white
    
    // The label color to be used for min range display. Default is black.
    public var minMaxDisplayLabelColor: UIColor = .black
    
    // The color for segment button when it is within the selected range. Default is clear.
    public var segmentSelectedColor: UIColor = .clear
    
    // The color for segment button when it is outside the selected range. Default is white.
    public var segmentUnSelectedColor: UIColor = .white
    
    // The image used for displaying slider buttons. By default "ic_sliderButton". rangeSliderButtonColor will be used if not set
    public var rangeSliderButtonImage: UIImage?
    
    // The image for segment button when it is within the selected range. If not set, segmentSelectedColor will be used.
    public var segmentSelectedImage: UIImage?
    
    // The image for segment button when it is outside the selected range. If not set, segmentUnSelectedColor will be used.
    public var segmentUnSelectedImage: UIImage?
    
    // The size of the slider button. If not set, defaults to (16, 16).
    public var sliderSize: CGSize = CGSize(width: 16, height: 16)
    
    // The size of the segments. If not set, defaults to (4, 4).
    public var segmentSize: CGSize = CGSize(width: 4, height: 4)
    
    // The min and max range label text to be set by caller
    public var minRangeText: String?
    public var maxRangeText: String?
    
    // The delegate property
    weak var delegate: CustomSliderDelegate?
    
    // PRIVATE VAR
    // Slider button size
    private var SLIDER_BUTTON_WIDTH: CGFloat = 44.0
    
    // Slider frame
    private var DEFAULT_SLIDER_FRAME: CGRect!
    
    // Segment width
    private var segmentWidth: CGFloat!
    
    // The backgroundView represent unselected/outside range view
    private var sliderBackgroundView: UIView!
    
    // The foregroundView represent selected/inside range view
    private var sliderForegroundView: UIView!
    
    // The label placed below the min and max sliders
    private var minRangeView: UIView!
    private var maxRangeView: UIView!
    private var minRangeLabel: UILabel!
    private var maxRangeLabel: UILabel!
    
    // min and max value
    private var minLabel: UILabel!
    private var maxLabel: UILabel!
    
    // Represent the range slider on either side of the slider
    private var startSliderButton: UIButton!
    private var endSliderButton: UIButton!
    
    // The segment index or percent for initial slider position loading for segmented and unsegmented respectively
    private var minRangeInitialIndex: Int?
    private var maxRangeInitialIndex: Int?
    
    // Padding range view with slider button
    private let iconRangeMidView = "ic_rangeMidView"
    private let iconRangeView = "ic_rangeView"
    private let iconSliderButton = "ic_sliderButton"
    private let iconSegmentUnSelected = "ic_segmentUnSelected"
    private let paddingRangeView: CGFloat = 4
    
    private var sliderMidView: UIView!
    private var sliderMidLabel: UILabel!
    private var checkInit: Bool = false
    // MARK: init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    func setUpUI() {
        setDefaultValues()
        initSliderViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
}

// MARK: - Public functions
extension CustomSlider {
    
    // Scroll to desired location on loading
    func scrollStartSlider(to startIndex: Int, andEnd endIndex: Int) {
        minRangeInitialIndex = startIndex
        maxRangeInitialIndex = endIndex
        if checkInit {
            slideRangeSliderButtonsIfNeeded()
        }
    }
    
    // MARK: - Setter methods
    func setNumberOfSegments(_ numberOfSegments: Int, minText: String?, maxText: String?) {
        self.numberOfSegments = numberOfSegments
        
        // After setting the numberOfSegments, set all the necessary views
        segmentWidth = getSegmentWidth(forSegmentCount: self.numberOfSegments)
        addSegmentButtons()
        addSubview(startSliderButton)
        addSubview(endSliderButton)
        minLabel.text = minText
        maxLabel.text = maxText
    }
    
    private func addSegmentButtons() {
        for segmentIndex in 1...numberOfSegments {
            let segmentButton = getSegmentButton(withSegmentIndex: segmentIndex, isSlider: false)
            segmentButton.tag = segmentIndex
            segmentButton.isUserInteractionEnabled = false
            addSubview(segmentButton)
        }
    }
}

// MARK: setup UI
extension CustomSlider {
    
    // Default Initializaer
    private func setDefaultValues() {
        checkInit = false
        numberOfSegments = 2
        shouldSliderButtonOverlap = false
        
        minRangeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        minRangeLabel.textColor = rangeDisplayLabelColor
        minRangeLabel.textAlignment = .center
        minRangeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        minRangeView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 29))
        minRangeView.center = CGPoint(x: SLIDER_BUTTON_WIDTH / 2, y: bounds.midY - (SLIDER_BUTTON_WIDTH / 2) - (paddingRangeView / 2))
        if let image = UIImage(named: iconRangeView) {
            minRangeView.backgroundColor = UIColor(patternImage: image)
        }
        addSubview(minRangeView)
        minRangeView.addSubview(minRangeLabel)
        
        maxRangeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        maxRangeLabel.textColor = rangeDisplayLabelColor
        maxRangeLabel.textAlignment = .center
        maxRangeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        maxRangeView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 29))
        maxRangeView.center = CGPoint(x: SLIDER_BUTTON_WIDTH / 2, y: bounds.midY + (SLIDER_BUTTON_WIDTH / 2) + (paddingRangeView / 2))
        if let image = UIImage(named: iconRangeView) {
            maxRangeView.backgroundColor = UIColor(patternImage: image)
        }
        addSubview(maxRangeView)
        maxRangeView.addSubview(maxRangeLabel)
        
        minLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        minLabel.center = CGPoint(x: SLIDER_BUTTON_WIDTH / 2, y: bounds.midY + (SLIDER_BUTTON_WIDTH / 2))
        minLabel.textColor = minMaxDisplayLabelColor
        minLabel.textAlignment = .center
        minLabel.font = .systemFont(ofSize: 12, weight: .regular)
        addSubview(minLabel)
        
        maxLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        maxLabel.center = CGPoint(x: bounds.maxX - SLIDER_BUTTON_WIDTH, y: bounds.midY + (SLIDER_BUTTON_WIDTH / 2))
        maxLabel.textColor = minMaxDisplayLabelColor
        maxLabel.textAlignment = .center
        maxLabel.font = .systemFont(ofSize: 12, weight: .regular)
        addSubview(maxLabel)
        
        // Mid View
        sliderMidLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 49, height: 24))
        sliderMidLabel.textColor = rangeDisplayLabelColor
        sliderMidLabel.textAlignment = .center
        sliderMidLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        sliderMidView = UIView(frame: CGRect(x: 0, y: 0, width: 49, height: 29))
        sliderMidView.center = CGPoint(x: SLIDER_BUTTON_WIDTH / 2, y: bounds.midY + (SLIDER_BUTTON_WIDTH / 2) + (paddingRangeView / 2))
        if let image = UIImage(named: iconRangeMidView) {
            sliderMidView.backgroundColor = UIColor(patternImage: image)
        }
        addSubview(sliderMidView)
        sliderMidView.addSubview(sliderMidLabel)
        sliderMidView.alpha = 0
        
        segmentWidth = getSegmentWidth(forSegmentCount: numberOfSegments)
        rangeSliderButtonImage = UIImage(named: iconSliderButton)
        segmentUnSelectedImage = UIImage(named: iconSegmentUnSelected)
        
    }
    
    // Init the sliding representing views
    private func initSliderViews() {
        DEFAULT_SLIDER_FRAME = CGRect(x: SLIDER_BUTTON_WIDTH / 2, y: self.bounds.midY, width: self.bounds.width - SLIDER_BUTTON_WIDTH, height: 4)
        
        sliderBackgroundView = UIView(frame: DEFAULT_SLIDER_FRAME)
        sliderBackgroundView.backgroundColor = rangeSliderBackgroundColor
        addSubview(sliderBackgroundView)
        
        sliderForegroundView = UIView(frame: DEFAULT_SLIDER_FRAME)
        sliderForegroundView.backgroundColor = rangeSliderForegroundColor
        addSubview(sliderForegroundView)
        
        startSliderButton = getSegmentButton(withSegmentIndex: 1, isSlider: true)
        addSubview(startSliderButton)
        
        endSliderButton = getSegmentButton(withSegmentIndex: numberOfSegments, isSlider: true)
        addSubview(endSliderButton)
        
        // Pan gesture for identifying the sliding (More accurate than touchesMoved).
        addPanGestureRecognizer()
    }
    
    // Update the frames
    private func updateFrame() {
        if self.numberOfSegments >= 2 {
            // If the range selectors are at the extreme points, then reset the frame. Else fo nothing
            if isRangeSlidersPlacedAtExtremePosition() {
                DEFAULT_SLIDER_FRAME = CGRect(x: SLIDER_BUTTON_WIDTH / 2, y: self.bounds.midY, width: self.bounds.width - SLIDER_BUTTON_WIDTH, height: 4)
                self.sliderBackgroundView.frame = DEFAULT_SLIDER_FRAME
                self.sliderForegroundView.frame = DEFAULT_SLIDER_FRAME
                
                self.sliderBackgroundView.backgroundColor = self.rangeSliderBackgroundColor
                self.sliderForegroundView.backgroundColor = self.rangeSliderForegroundColor
                
                segmentWidth = getSegmentWidth(forSegmentCount: numberOfSegments)
                
                startSliderButton.center = CGPoint(x: SLIDER_BUTTON_WIDTH / 2, y: sliderBackgroundView.frame.midY)
                endSliderButton.center = getSegmentCenterPoint(forSegmentIndex: numberOfSegments)
                
                minRangeView.center = CGPoint(x: startSliderButton.frame.midX, y: bounds.midY - (SLIDER_BUTTON_WIDTH / 2) - (paddingRangeView / 2))
                maxRangeView.center = CGPoint(x: endSliderButton.frame.midX, y: bounds.midY - (SLIDER_BUTTON_WIDTH / 2) - (paddingRangeView / 2))
                
                minLabel.center = CGPoint(x: startSliderButton.frame.midX, y: bounds.midY + (SLIDER_BUTTON_WIDTH / 2))
                maxLabel.center = CGPoint(x: endSliderButton.frame.midX, y: bounds.midY + (SLIDER_BUTTON_WIDTH / 2))
                
                sliderMidView.center = CGPoint(x: startSliderButton.frame.midX, y: bounds.midY - (SLIDER_BUTTON_WIDTH / 2) - (paddingRangeView / 2))
                
                setImageForSegmentOrSliderButton(startSliderButton, isSlider: true)
                setImageForSegmentOrSliderButton(endSliderButton, isSlider: true)
                
                // Reset the frame of all the intermediate buttons
                for segmentIndex in 1...numberOfSegments {
                    let segmentButton = self.viewWithTag(segmentIndex) as? UIButton
                    segmentButton?.center = getSegmentCenterPoint(forSegmentIndex: segmentIndex)
                    if let button = segmentButton {
                        setImageForSegmentOrSliderButton(button, isSlider: false)
                    }
                }
                
                // Slide the buttons if the initial position is needed
                slideRangeSliderButtonsIfNeeded()
                checkInit = true
            }
        }
    }
}
// MARK: - Calculations for moving the rangeSliders
extension CustomSlider {
    private func isRangeSlidersPlacedAtExtremePosition() -> Bool {
        let sliderBackgroundViewMaxX = sliderBackgroundView.frame.maxX + (SLIDER_BUTTON_WIDTH / 2)
        return (startSliderButton.frame.minX == 0.0 && endSliderButton.frame.maxX == sliderBackgroundViewMaxX)
    }
    
    private func slideRangeSliderButtonsIfNeeded() {
        var startScrollPoint = CGPoint.zero
        var endScrollPoint = CGPoint(x: bounds.size.width, y: 0)
        if let min = minRangeInitialIndex, let max = maxRangeInitialIndex, min < max {
            let startX = getSegmentCenterPoint(forSegmentIndex: min).x
            startScrollPoint.x = startX > (SLIDER_BUTTON_WIDTH / 2) ? startX : SLIDER_BUTTON_WIDTH / 2
            let endX = getSegmentCenterPoint(forSegmentIndex: max).x
            endScrollPoint.x = endX > (SLIDER_BUTTON_WIDTH / 2) ? endX : SLIDER_BUTTON_WIDTH / 2
        }
        scrollStartAndEndSlider(for: startScrollPoint, andEndScroll: endScrollPoint)
        minRangeInitialIndex = 0
        maxRangeInitialIndex = 0
    }
    
    private func scrollStartAndEndSlider(for startScrollPoint: CGPoint, andEndScroll endScrollPoint: CGPoint) {
        startSliderButton.isSelected = true
        sliderDidSlide(for: startScrollPoint)
        startSliderButton.isSelected = false
        
        endSliderButton.isSelected = true
        sliderDidSlide(for: endScrollPoint)
        endSliderButton.isSelected = false
    }
}

// MARK: - Pan Gesture for handling slider movements
extension CustomSlider {
    
    private func addPanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
    }
    
    // Pan Gesture selector method
    
    @objc
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let point = panGesture.location(in: self)
        
        if panGesture.state == .began {
            self.setSelectedStateForSlidingButton(point)
        } else if panGesture.state == .changed {
            sliderDidSlide(for: point)
        } else if panGesture.state == .ended || panGesture.state == .failed || panGesture.state == .cancelled {
            // Move the slider to nearest segment
            moveSliderToNearestSegment(withEnding: point)
            resetSelectedStateForSlidingButtons()
        }
    }
    
    // If sliding began, check if startSlider is moved or endSlider is moved
    private  func setSelectedStateForSlidingButton(_ point: CGPoint) {
        if startSliderButton.frame.contains(point) {
            startSliderButton.isSelected = true
            endSliderButton.isSelected = false
        } else if endSliderButton.frame.contains(point) {
            endSliderButton.isSelected = true
            startSliderButton.isSelected = false
        } else {
            startSliderButton.isSelected = false
            endSliderButton.isSelected = false
        }
    }
    
    private func sliderDidSlide(for point: CGPoint) {
        var newPoint = point
        // Check if startButton is moved or endButton is moved. Based on the moved button, set the frame of the slider button and foregroundSliderView
        newPoint = resetFrameOnBoundsCross(for: point)
        
        if startSliderButton.isSelected {
            if shouldStartButtonSlide(for: newPoint) {
                UIView.animate(withDuration: 0.1, animations: {
                    // Change only the x value for startbutton
                    self.startSliderButton.frame = CGRect(x: self.sliderMidPoint(forPoint: newPoint.x), y: self.startSliderButton.frame.origin.y, width: self.startSliderButton.frame.size.width, height: self.startSliderButton.frame.size.height)
                    
                    // Change the x and width for slider foreground view
                    if self.shouldSliderButtonOverlap {
                        let startMidX = self.startSliderButton.frame.midX
                        let endMidX = self.endSliderButton.frame.midX
                        var originX = self.startSliderButton.frame.origin.x
                        if endMidX < startMidX {
                            originX = self.endSliderButton.frame.origin.x
                        }
                        self.sliderForegroundView.frame = CGRect(x: originX + self.SLIDER_BUTTON_WIDTH / 2, y: self.sliderForegroundView.frame.origin.y, width: self.getSliderViewWidth(), height: self.sliderForegroundView.frame.size.height)
                    } else {
                        let originX = self.startSliderButton.frame.origin.x + self.SLIDER_BUTTON_WIDTH / 2
                        self.sliderForegroundView.frame = CGRect(x: originX, y: self.sliderForegroundView.frame.origin.y, width: self.getSliderViewWidth(), height: self.sliderForegroundView.frame.size.height)
                    }
                    
                    // Change the x and width for slider foreground view
                    self.minRangeView.center = CGPoint(x: self.startSliderButton.frame.midX, y: self.startSliderButton.frame.minY - self.paddingRangeView)
                    
                    self.sliderMidView.center = CGPoint(x: self.endSliderButton.frame.midX, y: self.startSliderButton.frame.minY - self.paddingRangeView)
                    
                    // Update the intermediate segment colors
                    self.updateSegmentColor(for: newPoint)
                }, completion: { _ in
                    self.callScrollDelegate(point: newPoint, isStartSliderButton: true)
                })
            }
        } else if endSliderButton.isSelected {
            if shouldEndButtonSlide(for: newPoint) {
                UIView.animate(withDuration: 0.1, animations: {
                    // Change only the x value for endbutton
                    self.endSliderButton.frame = CGRect(x: self.sliderMidPoint(forPoint: newPoint.x), y: self.endSliderButton.frame.origin.y, width: self.endSliderButton.frame.size.width, height: self.endSliderButton.frame.size.height)
                    
                    // Change the x and width for slider foreground view
                    if self.shouldSliderButtonOverlap {
                        let startMidX = self.startSliderButton.frame.midX
                        let endMidX = self.endSliderButton.frame.midX
                        var originX = self.startSliderButton.frame.origin.x
                        if endMidX < startMidX {
                            originX = self.endSliderButton.frame.origin.x
                        }
                        self.sliderForegroundView.frame = CGRect(x: originX + self.SLIDER_BUTTON_WIDTH / 2, y: self.sliderForegroundView.frame.origin.y, width: self.getSliderViewWidth(), height: self.sliderForegroundView.frame.size.height)
                    } else {
                        let originX = self.startSliderButton.frame.origin.x + self.SLIDER_BUTTON_WIDTH / 2
                        self.sliderForegroundView.frame = CGRect(x: originX, y: self.sliderForegroundView.frame.origin.y, width: self.getSliderViewWidth(), height: self.sliderForegroundView.frame.size.height)
                    }
                    
                    // Change the x and width for slider foreground view
                    self.maxRangeView.center = CGPoint(x: self.endSliderButton.frame.midX, y: self.endSliderButton.frame.minY - self.paddingRangeView)
                    
                    self.sliderMidView.center = CGPoint(x: self.startSliderButton.frame.midX, y: self.endSliderButton.frame.minY - self.paddingRangeView)
                    
                    // Update the intermediate segment colors
                    self.updateSegmentColor(for: newPoint)
                }, completion: { _ in
                    self.callScrollDelegate(point: newPoint, isStartSliderButton: false)
                })
            }
        }
    }
    
    // Method that handles if the sliders move out of range
    private func resetFrameOnBoundsCross(for point: CGPoint) -> CGPoint {
        var newPoint = point
        if shouldSliderButtonOverlap {
            if point.x < 0 {
                newPoint.x = 0
            } else if sliderMidPoint(forPoint: point.x) >= sliderBackgroundView.bounds.maxX {
                newPoint.x = sliderBackgroundView.bounds.maxX + SLIDER_BUTTON_WIDTH / 2
            }
        } else {
            if startSliderButton.isSelected {
                if sliderMidPoint(forPoint: point.x) >= endSliderButton.frame.midX - segmentWidth {
                    newPoint.x = endSliderButton.frame.midX - segmentWidth
                } else if point.x < 0 {
                    newPoint.x = 0
                }
            } else if endSliderButton.isSelected {
                if point.x <= startSliderButton.frame.midX + segmentWidth {
                    newPoint.x = startSliderButton.frame.midX + segmentWidth
                } else if sliderMidPoint(forPoint: point.x) >= sliderBackgroundView.bounds.maxX {
                    newPoint.x = sliderBackgroundView.bounds.maxX + SLIDER_BUTTON_WIDTH / 2
                }
            }
        }
        
        return newPoint
    }
    
    private func shouldStartButtonSlide(for point: CGPoint) -> Bool {
        if shouldSliderButtonOverlap {
            return (point.x >= (SLIDER_BUTTON_WIDTH / 2)) && (point.x <= (bounds.maxX - SLIDER_BUTTON_WIDTH / 2))
        } else {
            var endButtonMidPoint = endSliderButton.frame.midX
            endButtonMidPoint -= segmentWidth
            return round(point.x) <= round(endButtonMidPoint) && point.x >= SLIDER_BUTTON_WIDTH / 2
        }
    }
    
    private func shouldEndButtonSlide(for point: CGPoint) -> Bool {
        if shouldSliderButtonOverlap {
            return point.x >= SLIDER_BUTTON_WIDTH / 2
        } else {
            var startButtonMidPoint = startSliderButton.frame.midX
            startButtonMidPoint += shouldSliderButtonOverlap ? 0 : segmentWidth
            return round(point.x) >= round(startButtonMidPoint) && point.x <= sliderMidPoint(forPoint: frame.size.width)
        }
    }
    
    // Call the delegate to set the label for min range and max range
    private func callScrollDelegate(point: CGPoint, isStartSliderButton: Bool) {
        let nearestSegmentIndex = Int(round(sliderMidPoint(forPoint: point.x) / segmentWidth))
        
        var startIndex = Int(round(startSliderButton.frame.minX / segmentWidth))
        var endIndex = Int(round(endSliderButton.frame.minX / segmentWidth))
        
        if isStartSliderButton {
            startIndex = nearestSegmentIndex
        } else {
            endIndex = nearestSegmentIndex
        }
        updateData(startIndex: startIndex, endIndex: endIndex, endDragDrop: false)
    }
    
    private func updateData(startIndex: Int, endIndex: Int, endDragDrop: Bool) {
        if startIndex > endIndex {
            let min = endIndex < 0 ? 0 : endIndex
            let max = startIndex > numberOfSegments ? numberOfSegments : startIndex
            delegate?.sliderScrolled(self, toMinIndex: min, andMaxIndex: max, endDragDrop: endDragDrop)
            minRangeLabel.text = maxRangeText
            maxRangeLabel.text = minRangeText
        } else {
            let min = startIndex < 0 ? 0 : startIndex
            let max = endIndex > numberOfSegments ? numberOfSegments : endIndex
            delegate?.sliderScrolled(self, toMinIndex: min, andMaxIndex: max, endDragDrop: endDragDrop)
            minRangeLabel.text = minRangeText
            maxRangeLabel.text = maxRangeText
        }
        
        if startIndex != endIndex {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.sliderMidView.alpha = 0
                self.minRangeView.alpha = 1
                self.maxRangeView.alpha = 1
            } completion: { _ in
                print("completion \(startIndex) = \(endIndex)")
            }
        } else {
            sliderMidLabel.text = "\(minRangeText ?? "") - \(maxRangeText ?? "")"
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.sliderMidView.alpha = 1
                self.minRangeView.alpha = 0
                self.maxRangeView.alpha = 0
            } completion: { _ in
                print("completion \(startIndex) = \(endIndex)")
            }
        }
    }
    
    private func updateSegmentColor(for point: CGPoint) {
        
        if shouldSliderButtonOverlap {
            let startMinX = startSliderButton.frame.midX
            let endMinX = endSliderButton.frame.midX
            
            var min: CGFloat = 0.0
            var max: CGFloat = 0.0
            if startMinX > endMinX {
                min = (endSliderButton.frame.minX / segmentWidth).rounded(.up)
                max = (startSliderButton.frame.minX / segmentWidth).rounded(.down)
            } else {
                min = (startSliderButton.frame.minX / segmentWidth).rounded(.up)
                max = (endSliderButton.frame.minX / segmentWidth).rounded(.down)
            }
            updateSegmentColor(withStart: Int(min) + 1, andEnd: Int(max) + 1)
        } else {
            if startSliderButton.isSelected {
                let startMinX = (sliderMidPoint(forPoint: startSliderButton.frame.midX) / segmentWidth).rounded(.up)
                let endMinX = (sliderMidPoint(forPoint: endSliderButton.frame.midX) / segmentWidth).rounded(.up)
                updateSegmentColor(withStart: Int(startMinX) + 1, andEnd: Int(endMinX) + 1)
            } else if endSliderButton.isSelected {
                let startMinX = (startSliderButton.frame.minX / segmentWidth).rounded(.up)
                let endMinX = (endSliderButton.frame.minX / segmentWidth).rounded(.down)
                updateSegmentColor(withStart: Int(startMinX) + 1, andEnd: Int(endMinX) + 1)
            }
        }
        let pointX: Int = Int(round(point.x - SLIDER_BUTTON_WIDTH / 2))
        if pointX % Int(round(segmentWidth)) == 0 {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    private func updateSegmentColor(withStart startIndex: Int, andEnd endIndex: Int) {
        // Segments before startSegment slider
        
        if startIndex > 1 {
            for segmentIndex in 1..<startIndex {
                if let segmentButton = viewWithTag(segmentIndex) as? UIButton {
                    if let image = segmentUnSelectedImage {
                        segmentButton.setImage(image, for: .normal)
                    } else {
                        let image = getImageWithSize(segmentSize, with: segmentUnSelectedColor)
                        segmentButton.setImage(image, for: .normal)
                    }
                }
            }
        }
        
        // Segments between startSegment slider and endSegment slider
        if startIndex <= endIndex {
            for segmentIndex in startIndex...endIndex {
                if let segmentButton = viewWithTag(segmentIndex) as? UIButton {
                    if let image = segmentSelectedImage {
                        segmentButton.setImage(image, for: .normal)
                    } else {
                        let image = getImageWithSize(segmentSize, with: segmentSelectedColor)
                        segmentButton.setImage(image, for: .normal)
                    }
                }
            }
        }
        
        // Segments after endSegment slider
        if endIndex + 1 <= numberOfSegments {
            for segmentIndex in (endIndex + 1)...numberOfSegments {
                if let segmentButton = viewWithTag(segmentIndex) as? UIButton {
                    if let image = segmentUnSelectedImage {
                        segmentButton.setImage(image, for: .normal)
                    } else {
                        let image = getImageWithSize(segmentSize, with: segmentUnSelectedColor)
                        segmentButton.setImage(image, for: .normal)
                    }
                }
            }
        }
    }
    
    // Slide to nearest position
    private func moveSliderToNearestSegment(withEnding point: CGPoint) {
        var newPoint = point
        newPoint = resetFrameOnBoundsCross(for: point)
        
        let nearestSegmentIndex = Int(round(sliderMidPoint(forPoint: newPoint.x) / segmentWidth))
        sliderDidSlide(for: CGPoint(x: CGFloat(SLIDER_BUTTON_WIDTH / 2 + CGFloat(nearestSegmentIndex) * segmentWidth), y: newPoint.y))
        
        var startIndex = Int(round(startSliderButton.frame.minX / segmentWidth))
        var endIndex = Int(round(endSliderButton.frame.minX / segmentWidth))
        
        if startSliderButton.isSelected {
            startIndex = nearestSegmentIndex
        } else if endSliderButton.isSelected {
            endIndex = nearestSegmentIndex
        }
        updateData(startIndex: startIndex, endIndex: endIndex, endDragDrop: true)
    }
    
    // After ending, reset the selected state of both buttons
    private func resetSelectedStateForSlidingButtons() {
        startSliderButton.isSelected = false
        endSliderButton.isSelected = false
    }
}

// MARK: - Calculation for slider frame
extension CustomSlider {
    private func getSliderViewWidth() -> CGFloat {
        let startMinX = startSliderButton.frame.midX
        let endMinX = endSliderButton.frame.midX
        if startMinX > endMinX {
            return startMinX - endMinX
        } else {
            return endMinX - startMinX
        }
    }
    
    private func sliderMidPoint(forPoint point: CGFloat) -> CGFloat {
        let sliderMidPoint = point - (SLIDER_BUTTON_WIDTH / 2)
        return sliderMidPoint
    }
    
    private func getSegmentWidth(forSegmentCount segmentCount: Int) -> CGFloat {
        let segmentCount = CGFloat(segmentCount - 1)
        let sliderWidth = frame.width - SLIDER_BUTTON_WIDTH
        return sliderWidth / segmentCount
    }
    
    private func getSegmentButton(withSegmentIndex segmentIndex: Int, isSlider: Bool) -> UIButton {
        // Create rounded button for representing slider segments
        let segmentButton = UIButton(type: .custom)
        segmentButton.frame = CGRect(x: 0, y: 0, width: SLIDER_BUTTON_WIDTH, height: SLIDER_BUTTON_WIDTH)
        segmentButton.center = getSegmentCenterPoint(forSegmentIndex: segmentIndex)
        setImageForSegmentOrSliderButton(segmentButton, isSlider: isSlider)
        return segmentButton
    }
    
    // MARK: - Calculation for segment button frame
    private func getSegmentCenterPoint(forSegmentIndex segmentIndex: Int) -> CGPoint {
        let pointX = CGFloat((CGFloat(segmentIndex - 1) * segmentWidth) + (SLIDER_BUTTON_WIDTH / 2))
        return CGPoint(x: pointX, y: sliderBackgroundView.frame.midY)
    }
    
    private func setImageForSegmentOrSliderButton(_ button: UIButton, isSlider: Bool) {
        if let image = rangeSliderButtonImage, isSlider {
            button.setImage(image, for: .normal)
        } else if let iamge = segmentSelectedImage {
            button.setImage(iamge, for: .normal)
        } else {
            button.setImage(getImageWithSize(isSlider ? sliderSize : segmentSize, with: segmentSelectedColor), for: .normal)
        }
        
        button.imageView?.layer.masksToBounds = true
        let buttonWidth = button.imageView?.frame.size.width ?? button.frame.size.width
        button.imageView?.layer.cornerRadius = buttonWidth / 2
    }
    
    private func getImageWithSize(_ size: CGSize, with backgroundColor: UIColor?) -> UIImage? {
        let imageView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        imageView.backgroundColor = backgroundColor
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: size.height), false, 1.0)
        if let context = UIGraphicsGetCurrentContext() {
            imageView.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
