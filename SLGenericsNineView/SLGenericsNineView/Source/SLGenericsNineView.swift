//
//  SLGenericsNineView
//  SLGenericsNineView
//
//  Created by 一声雷 on 2017/8/28.
//  Copyright © 2017年 che300. All rights reserved.
//

import UIKit

public class SLGenericsNineView<ItemView:UIView, ItemModel>: UIView {
    
    /// 数据源
    public var dataArr:[ItemModel]?{
        didSet{
            self.reloadData()
        }
    }
    
    /// 刷新列表数据
    public func reloadData(){
        if dataArr?.count == self.subviews.count{
            // 1.只是进行子控件的数据更新
            for (i , subView) in self.subviews.enumerated(){
                if let view = subView as? ItemView, let model = dataArr?[i]{
                    self.map(view, model)
                }
            }
        }else{
            // 2.删除原先的子控件,进行重新布局
            creatAllItems()
        }
    }
    /// 每个item点击以后的回调闭包
    public var itemClicked:((_ itemView:ItemView, _ model:ItemModel, _ index:Int)->Void)?
    
    private var map:((_ cell:ItemView, _ itemModel:ItemModel)->Void)
    /// - Parameters:
    ///   - frame: 控件的frame,请确定控件的width
    ///   - map:映射函数,控件和模型直接的数据赋值关系
    public init(frame: CGRect, map:@escaping (_ cell:ItemView, _ itemModel:ItemModel)->Void) {
        self.map = map
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray
    }
    
    public var topMargin:CGFloat    = 0
    public var leftMargin:CGFloat   = 0
    public var rightMargin:CGFloat  = 0
    public var bottomMargin:CGFloat = 0
    // 水平方向 间距
    public var horizontalSpace:CGFloat = 1
    // 垂直方向 间距
    public var verticalSpace:CGFloat   = 1
    public var everyRowCount:Int = 3
    public var itemHeight:CGFloat = 80
    public var itemWidth:CGFloat{
        get{
            let everyRowBtnsWidth = totalWidth - CGFloat(everyRowCount-1)*horizontalSpace - leftMargin - rightMargin
            return everyRowBtnsWidth/CGFloat(everyRowCount)
        }
    }
    
    public var totalWidth:CGFloat{
        return self.frame.width
    }
    public var totalHeight:CGFloat{
        guard let count = dataArr?.count else{
            return 0
        }
        var rowCount = 0
        if count % everyRowCount == 0{
            rowCount = count / everyRowCount
        }else{
            rowCount = count / everyRowCount + 1
        }
        let height = itemHeight*CGFloat(rowCount) + verticalSpace*CGFloat(rowCount-1) + topMargin + bottomMargin
        return height
    }
    
    private func creatAllItems(){
        guard let data = self.dataArr else{
            self.removeAllSubviews()
            return
        }
        self.removeAllSubviews()
        for ( i, data ) in data.enumerated(){
            
            let itemX = i % everyRowCount     //  处于第几列
            let itemY = i / everyRowCount     //  处于第几行
            
            let btn = ItemView.init()
            btn.tag = i
            let x = CGFloat(itemX)*horizontalSpace + CGFloat(itemX)*itemWidth + leftMargin
            let y = CGFloat(itemY)*verticalSpace + CGFloat(itemY)*itemHeight + topMargin
            btn.frame = CGRect(x: x, y: y, width: self.itemWidth, height: self.itemHeight)
            self.addSubview(btn)
            
            self.map(btn, data)
            // 添加点击手势
            let tap = UITapGestureRecognizer(target: self, action:#selector(SLGenericsNineView.cellClicked(_:)))
            tap.numberOfTouchesRequired = 1
            tap.numberOfTapsRequired    = 1
            btn.addGestureRecognizer(tap)
        }
        // 更新自身高度
        let size = CGSize(width: self.bounds.width, height: self.totalHeight)
        // 在首页布局,发现frame的Y值变动了...
        // 理论上来说,就应该来修改frame,而不应该修改bounds
        // bounds影响的是自身子控件的坐标系,而我们的目标是修改自身在父控件的大小...
        // self.bounds.size = size
        self.frame.size = size
    }
    
    // 手势的点击事件
    @objc func cellClicked(_ tap:UITapGestureRecognizer){
        if let cell = tap.view as? ItemView, let data = self.dataArr?[cell.tag]{
            self.itemClicked?(cell, data, cell.tag)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}







