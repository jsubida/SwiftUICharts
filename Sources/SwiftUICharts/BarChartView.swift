//
//  BarChartView.swift
//  SwiftUICharts
//
//  Created by Majid Jabrayilov on 6/21/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//
import SwiftUI

/// Type that defines a bar chart style.
public struct BarChartStyle: ChartStyle {
    /// Minimal height for a bar chart view
    public let barMinHeight: CGFloat
    /// Boolean value indicating whenever show chart axis
    public let showAxis: Bool
    /// Leading padding for the value axis displayed in the chart
    public let axisLeadingPadding: CGFloat
    /// Boolean value indicating whenever show chart labels
    public let showLabels: Bool
    /// The count of labels that should be shown below the chart. Nil value shows all the labels.
    public let labelCount: Int?
    public let showLegends: Bool
    
    /// The max value displayed on the y-axis
    public let maxY: Double?
    
    /**
     Creates new bar chart style with the following parameters.

     - Parameters:
        - barMinHeight: The minimal height for the bar that presents the biggest value. Default is 100.
        - showAxis: Bool value that controls whenever to show axis.
        - axisLeadingPadding: Leading padding for axis line. Default is 0.
        - showLabels: Bool value that controls whenever to show labels.
        - labelCount: The count of labels that should be shown below the chart. Default is all.
        - showLegends: Bool value that controls whenever to show legends.
     */
    #if os(watchOS)
    public init(
        barMinHeight: CGFloat = 50,
        showAxis: Bool = true,
        axisLeadingPadding: CGFloat = 0,
        showLabels: Bool = true,
        labelCount: Int? = nil,
        showLegends: Bool = true,
        maxY: Double? = nil
    ) {
        self.barMinHeight = barMinHeight
        self.showAxis = showAxis
        self.axisLeadingPadding = axisLeadingPadding
        self.showLabels = showLabels
        self.labelCount = labelCount
        self.showLegends = showLegends
        self.maxY = maxY
    }
    #else
    public init(
        barMinHeight: CGFloat = 100,
        showAxis: Bool = true,
        axisLeadingPadding: CGFloat = 0,
        showLabels: Bool = true,
        labelCount: Int? = nil,
        showLegends: Bool = true,
        maxY: Double? = nil
    ) {
        self.barMinHeight = barMinHeight
        self.showAxis = showAxis
        self.axisLeadingPadding = axisLeadingPadding
        self.showLabels = showLabels
        self.labelCount = labelCount
        self.showLegends = showLegends
        self.maxY = maxY
    }
    #endif
}

/// SwiftUI view that draws bars by placing them into a horizontal container.
public struct BarChartView: View {
    @Environment(\.chartStyle) var chartStyle

    let dataPoints: [DataPoint]
    let limit: DataPoint?
    
    /**
     Creates new bar chart view with the following parameters.

     - Parameters:
        - dataPoints: The array of data points that will be used to draw the bar chart.
        - limit: The horizontal line that will be drawn over bars. Default is nil.
     */
    public init(dataPoints: [DataPoint], limit: DataPoint? = nil) {
        // insert additional invisible data point to guarantee spacing
        self.dataPoints = dataPoints + [
            .init(
                value: (dataPoints.max()?.endValue ?? 0) * 1.2,
                label: "invisible",
                legend: .init(
                    color: .clear,
                    label: "clear"
                ),
                visible: false
            )
        ]

        self.limit = limit
    }

    private var style: BarChartStyle {
        (chartStyle as? BarChartStyle) ?? .init()
    }

    private var grid: some View {
        ChartGrid()
            .stroke(
                style.showAxis ? Color.accentColor : .clear,
                style: StrokeStyle(
                    lineWidth: 1,
                    lineCap: .round,
                    lineJoin: .round,
                    miterLimit: 0,
                    dash: [1, 8],
                    dashPhase: 0
                )
            )
    }

    public var body: some View {
        VStack {
            HStack(spacing: 0) {
                VStack {
                    BarsView(dataPoints: dataPoints, limit: limit, maxY: style.maxY)
                        .frame(minHeight: style.barMinHeight)
                        .background(grid)

                    if style.showLabels {
                        LabelsView(
                            dataPoints: dataPoints,
                            labelCount: style.labelCount ?? dataPoints.count
                        ).accessibilityHidden(true)
                    }
                }
                if style.showAxis {
                    AxisView(dataPoints: dataPoints, maxY: style.maxY)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibilityHidden(true)
                        .padding(.leading, style.axisLeadingPadding)
                }
            }

            if style.showLegends {
                LegendView(dataPoints: limit.map { [$0] + dataPoints} ?? dataPoints)
                    .padding()
                    .accessibilityHidden(true)
            }
        }
    }
}

#if DEBUG
struct BarChartView_Previews : PreviewProvider {
    static var previews: some View {
        let limit = Legend(color: .purple, label: "Trend")
        let limitBar = DataPoint(value: 100, label: "Trend", legend: limit)
        return HStack(spacing: 0) {
            BarChartView(dataPoints: DataPoint.mock, limit: limitBar)
                .chartStyle(BarChartStyle(showLabels: true, showLegends: false))
            BarChartView(dataPoints: DataPoint.mock, limit: limitBar)
                .chartStyle(BarChartStyle(showLabels: false, showLegends: false, maxY: 320.0))
        }
    }
}
#endif
