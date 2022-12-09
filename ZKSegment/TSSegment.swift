//
//  TSSegment.swift
//  Demo
//
//  Created by 王文壮 on 2018/3/22.
//  Copyright © 2018年 王文壮. All rights reserved.
//

import UIKit
 

public typealias TSItemChange = ((_ index: Int, _ text: String) -> Void)

public extension TSSegment {

    /// 创建 .rectangle 样式实例
    static func segmentRectangle(frame: CGRect,
                                 itemFont: UIFont?,
                                 itemSelectedFont: UIFont?,
                                        itemMargin: CGFloat?,
                                        items: [String] = [],
                                        change: TSItemChange?) -> TSSegment{
        
        return TSSegment(frame: frame,
                         itemFont: itemFont,
                         itemSelectedFont: itemSelectedFont,
                                itemMargin: itemMargin,
                                items:items,
                                change: change)
        
    }


}

public class TSSegment: UIScrollView {
    /// 获取当前选中项索引
    public var selectedIndex: Int? {
        get {
            if self.buttonSelected != nil {
                if let index = self.items.firstIndex(where: { $0 == self.buttonSelected?.titleLabel?.text }) {
                    return index
                }
            }
            return nil
        }
    }
    /// 获取当前选中项
    public var selectedItem: String? {
        get {
            if self.buttonSelected != nil {
                return self.buttonSelected?.titleLabel?.text
            }
            return nil
        }
    }
    
    //更改事件
    private var itemChange: TSItemChange?
   
    
    /// 默认显示项字体
    private var itemFont: UIFont!
    // 选中字体
    private var itemSelectedFont: UIFont!

    /// 每一项间距
    private var itemMargin: CGFloat = 20

    
    private var buttons: [UIButton] = []
    private var buttonSelected: UIButton?
    
//    private var itemStyle: UIView!
    private var itemStyleY: CGFloat = 0
    private var itemStyleHeight: CGFloat = 0
    
    /// .rectangle 样式圆角属性
    private let itemRectangleStyleCornerRadius: CGFloat = 8
    /// .rectangle 样式每项内间距
    private let itemRectangleStylePadding: CGFloat = 8
    
    ///scroll view的X的偏移量
    private var contentX: CGFloat = 0
    
    private var items: [String] = []
    
    private init(frame: CGRect,
                 itemFont: UIFont?,
                 itemSelectedFont: UIFont?,
                 itemMargin: CGFloat?,
                 items: [String],
                 change: TSItemChange?) {
        
        super.init(frame: frame)
     
        self.itemSelectedFont = itemSelectedFont ?? UIFont.systemFont(ofSize: 14)

        self.itemFont = itemFont ?? UIFont.systemFont(ofSize: 14)
        self.itemMargin = itemMargin ?? self.itemMargin
        self.itemChange = change
        
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        
        self.itemStyleY = self.itemRectangleStylePadding
        self.itemStyleHeight = self.height - self.itemStyleY * 2
        
        self.reload(items)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension TSSegment {
    /// 重新加载
    func reload(_ items: [String]) {
        self.items = items
        self.buttons.removeAll()
        self.subviews.forEach({ $0.removeFromSuperview() })
        ///  指示器只有一个 圆角什么的都设置好了 但是没有选中的也要设置 效果
//        self.itemStyle.isHidden = true
        
        self.contentX = self.itemMargin
//        self.addSubview(self.itemStyle)
        buttonSelected = nil
        self.items.forEach({ self.createItem($0) })
        self.contentSize = CGSize(width: self.contentX, height: -4)
        self.fiexItems()
        // 默认选中
        if let button =  buttons.first {
            itemClick(button: button)
        }
        
    }
    /// 根据索引选中
    func select(_ index: Int) {
        if index >= 0 {
            self.itemClick(button: self.buttons[index])
        }
    }
    /// 添加一项
//    func add(_ item: String, isSelected: Bool = false) {
////        if self.itemStyle.isHidden {
////            self.itemStyle.isHidden = false
////        }
//        self.items.append(item)
//        self.createItem(item)
//        self.resetitemsFrame()
//        self.fiexItems()
//    }
    /// 移除一项
    func remove(_ index: Int) {
        if index < 0 || index > self.items.count - 1 {
            print("TSSegment ->>>>>> error: remove 方法索引不对")
            return
        }
        self.items.remove(at: index)
        let button = self.buttons[index]
        self.buttons.remove(at: index)
        button.removeFromSuperview()
        if button == self.buttonSelected && self.buttons.count > 0 {
            var itemIndex = index
            if self.buttons.count >= index && index > 0 {
                itemIndex = index - 1
            }
            self.itemClick(button: self.buttons[itemIndex])
        }
        if self.buttons.count == 0 {
            self.buttonSelected = nil
//            self.itemStyle.isHidden = true
        }
//        self.resetitemsFrame()
        self.fiexItems()
        
    }
}

extension TSSegment {
    private func itemStyleFrame(_ x: CGFloat, _ width: CGFloat, _ buttonText: String?) -> CGRect {
        var styleX = x
        var styleWidth = width
 
        return CGRect(
            x: styleX,
            y: self.itemStyleY,
            width: styleWidth,
            height: self.itemStyleHeight
        )
    }
    
    private func createItem(_ item: String) {
        let itemWidth = self.itemWidth(item)
        let button = UIButton(frame: CGRect(x: self.contentX, y: 5, width: itemWidth, height: self.height - 10))
        button.titleLabel?.font = self.itemFont
        button.setTitle(item, for: .normal)
        button.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), for: .normal)
       
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        
        
        button.addTarget(self, action: #selector(TSSegment.itemClick(button:)), for: .touchUpInside)
        self.contentX += (itemWidth + self.itemMargin)
        self.buttons.append(button)
        self.addSubview(button)
 
    }
    
    @objc private func itemClick(button: UIButton) {
        /// 当前点击按钮不是 之前点击按钮
        if self.buttonSelected != button {
            // 当前点击按钮
             self.buttonSelected = button
            
            /// 设置当前点击按钮 为选中按钮 设置样式
            _ =  buttons.compactMap({ btn1 in
                
                if btn1 == self.buttonSelected  {
                    btn1.backgroundColor  = UIColor(red: 0.01, green: 0.69, blue: 0.4, alpha: 1)
                    btn1.titleLabel?.font =   self.itemSelectedFont
                    btn1.setTitleColor(UIColor.white, for: .normal)
                 }else{
                    btn1.backgroundColor =  UIColor.white
                     btn1.titleLabel?.font =   self.itemFont
                    btn1.setTitleColor(UIColor.black, for: .normal)
                }
            })
             
            /// 翻出选中的索引和文字
            if let change = self.itemChange {
                change(self.selectedIndex ?? -1, self.selectedItem ?? "")
            }
            /// 做动画 X方向移动 或者 加一个指示器移动
            self.animateChage(button)
        }
    }
    
    private func animateChage(_ button: UIButton) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: UIView.AnimationOptions.curveEaseOut,
            animations: {
                // 这里可以加指示器 变化指示器的w 和x 做动画
//                self.itemStyle.frame = self.itemStyleFrame(button.x, button.width, button.titleLabel?.text)
        }, completion: { finished in
            UIView.animate(withDuration: 0.3, animations: {
                /// 移动到中间
                if self.contentSize.width > self.width &&                                               // 内容宽度大于控件宽度
                    button.x > self.width / 2 - button.width / 2 &&                                     // 按钮的坐标大于屏幕中间位置
                    self.contentSize.width > button.x + self.width / 2 + button.width / 2 {             //内容的宽度大于按钮移动到中间坐标加上屏幕一半宽度加上按钮一半宽度
                    self.contentOffset = CGPoint(
                        x: button.x - self.width / 2 + button.width / 2,
                        y: 0)
                } else if button.x < self.width / 2 - button.width / 2 {                                // 移动到开始
                    self.contentOffset = CGPoint(x: 0, y: 0)
                } else if self.contentSize.width - button.x < self.width / 2 + button.width / 2 ||      // 内容宽度减去按钮的坐标小于屏幕的一半，移动到最后
                    button.x + button.width + self.itemMargin == self.contentSize.width {
                    if self.contentSize.width > self.width {
                        self.contentOffset = CGPoint(x: self.contentSize.width - self.width, y: 0)      // 移动到末尾
                    }
                }
            })
        })
    }
    
    /// 根据样式获取项宽度
    private func itemWidth(_ item: String) -> CGFloat {
        let itemWidth = item.sizeTS(self.itemFont).width
        // 按钮的宽等于左右间距 加文字宽
        return itemWidth + self.itemMargin * 2
    }
    
    /// 如果内容宽度小于控件宽度，居中显示
    private func fiexItems() {
        if (self.width - self.contentX > self.itemMargin) {
            var bigItemSumWidth: CGFloat = 0
            var bigItemCount: CGFloat = 0
            self.contentX = self.itemMargin
            // 计算平均每项宽度
            var itemWidth = (self.width - (CGFloat(self.buttons.count) + 1) * self.itemMargin) / CGFloat(self.buttons.count)
            // 检查是否有超过平均宽度的项
            self.buttons.forEach({ button in
                if button.width > itemWidth {
                    bigItemCount += 1
                    bigItemSumWidth += button.width
                }
            })
            // 减去超过平均宽度项的宽度总和，重新计算剩余项的宽度
            itemWidth = (self.width - (CGFloat(self.buttons.count) + 1) * self.itemMargin - bigItemSumWidth) / (CGFloat(self.buttons.count) - bigItemCount)
            // 重新布局
            self.buttons.forEach({ button in
                // 如果小于平均宽度，设置为平均宽度
                if button.width < itemWidth {
                    button.frame = CGRect(x: self.contentX, y: 0, width: itemWidth, height: self.height)
                    self.contentX += (itemWidth + self.itemMargin)
                } else {
                    button.frame = CGRect(x: self.contentX, y: 0, width: button.width, height: self.height);
                    self.contentX += (button.width + self.itemMargin)
                }
                if button == self.buttonSelected {
                    /// 选中的按钮样式
                    button.backgroundColor  = UIColor(red: 0.01, green: 0.69, blue: 0.4, alpha: 1)
                    button.titleLabel?.font =   self.itemSelectedFont
                    button.setTitleColor(UIColor.white, for: .normal)
                }
            })
            self.contentSize = CGSize(width: self.contentX, height: -4)
        }
    }

}

extension String {
    func sizeTS(_ font: UIFont) -> CGSize {
        let attribute = [ NSAttributedString.Key.font: font ]
        let conten = NSString(string: self)
        return conten.boundingRect(
            with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)),
            options: .usesLineFragmentOrigin,
            attributes: attribute,
            context: nil
            ).size
    }
}
//
//extension UIView {
//    var x: CGFloat {
//        get {
//            return self.frame.origin.x
//        }
//    }
//
//    var y: CGFloat {
//        get {
//            return self.frame.origin.y
//        }
//    }
//
//    var width: CGFloat {
//        get {
//            return self.frame.size.width
//        }
//    }
//
//    var height: CGFloat {
//        get {
//            return self.frame.size.height
//        }
//    }
//}
