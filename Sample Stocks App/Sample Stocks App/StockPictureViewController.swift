//
//  StockPictureViewController.swift
//  Stocks App
//
//  Created by Saurabh Soni on 04/09/23.
//

import SwiftUI
import Charts

//struct Joke: Codable{
//
//    var categories: [String]
//    var created_at: String
//    var icon_url: String
//    var id: String
//    var updated_at: String
//    var value: String
//
//
//
//}

struct HistoricalStat: Codable {
    var c: [Double]
    var h: [Double]
    var l: [Double]
    var o: [Double]
    var s: String
    var t: [Int]
    var v: [Int]
}

struct StockPictureViewController: View {
    let symbol: String
    @State public var dataPrices: HistoricalStat
    @State public var maxY: Double
    @State public var minY: Double
    @State public var percent: CGFloat = 0
    @State public var timeSpan: Double = 0
    
    
    var body: some View {
        
        VStack{

            Text(" \(symbol)")
                .foregroundColor(Color.green)
                .font(.system(size: 32))
                .padding()
            
            Text("Opening price for last : \(Int(timeSpan)) months with max \(maxY) and min \(minY) opening price")
                .foregroundColor(Color.black)
                .font(.system(size: 21))
                .padding()
            
            
            
            
            Slider(value: $timeSpan, in: 1...12, step: 1, onEditingChanged: { editing in
                if !editing {
                    // Fetch data when the user stops editing the slider
                    print("this is the timeSpan : \(timeSpan)")
                    let stDate = "1662575597"
                    let endDate = "\(Int(timeSpan*2629743) + 1662575597)"
                    fetchData(startDate: stDate, endDate: endDate)
                }
            })
            .padding()
            .tint(.red)
            chartHeading
            stockPictureView
                .frame(height: 400)
                .background(chartBg)
                .overlay(chartAxis,alignment: .leading)
                .onAppear {
                    fetchData(startDate: "1694120742", endDate: "1662584742")
                }
                .background(Color.black)
            
            chartDate
            
        }
        .font(.caption)
        .foregroundColor(Color.white)
//        .onAppear(perform: fetchData)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 ){
                withAnimation(.linear(duration: 2.0)){
                    percent = 1.0
                }
            }
        }
    }
    
}

struct StockPictureViewController_Previews: PreviewProvider {
    static var previews: some View {
        let sample = HistoricalStat(c:[258.39,257.86],h:[258.53,258.38],l:[258.25,257.83],o:[258.51,258.38],s:"ok",t:[1693493400,1693493460],v:[232485,315044])
        StockPictureViewController(symbol: "APPL", dataPrices: sample, maxY: 4.0, minY: 1.1)
//        StockPictureViewController(symbol: sample, dataPrices: [1.1, 2.2,4.0,3.2], maxY: 4.0, minY: 1.1)
//        (symbol: "APPL", dataPrices: [1.1, 2.2,4.0,3.2], maxY: 4.0, minY: 1.1)
    }
}

extension StockPictureViewController{
    
    private var stockPictureView: some View{
        
        
        
        GeometryReader { geometry in
            Path { path in
                
                for index in dataPrices.o.indices {
                    
                    let xPosition = geometry.size.width / CGFloat (dataPrices.o.count) * CGFloat(index + 1)
                    
                    let yAxis = maxY - minY
                    
                    let yPosition = (1 - CGFloat ( (dataPrices.o[index] - minY) / yAxis)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .trim(from: 0, to:percent)
            .stroke(Color.green, style: StrokeStyle(lineWidth: 2 , lineCap: .round,
                                                    lineJoin: .round))
            .shadow(color: Color.green, radius: 10, x: 0.0, y: 0.0)
        }
    }
    
    public func fetchData(startDate: String, endDate: String) {
        //Parse URL
        guard let url = URL(string: "https://finnhub.io/api/v1/stock/candle?" + "symbol=" + symbol + "&resolution=1&from=" + startDate + "&to=" + endDate + "&token=cjf5olhr01qhblojnrb0cjf5olhr01qhblojnrbg") else { return }
        print("test")
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    //Parse JSON
                    let decodedData = try JSONDecoder().decode(HistoricalStat.self, from: data)
                    self.dataPrices = decodedData
                    self.minY = self.dataPrices.o.min() ?? 0
                    self.maxY = self.dataPrices.o.max() ?? 0
                } catch {
                    //Print JSON decoding error
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            } else if let error = error {
                //Print API call error
                print("Error fetching data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    private var chartBg: some View{
        VStack{
            Divider()
            Spacer()
            Divider().background(Color.white)
            Spacer()
            Divider()
            
        }
    }
    
    private var chartAxis: some View{
        VStack{
            Text("\(maxY)")
                .font(.system(size: 12))
            Spacer()
            let mid = (maxY+minY)/2
            Text("\(mid)")
                .font(.system(size: 12))
            Spacer()
            Text("\(minY)")
                .font(.system(size: 12))
        }
    }
    
    private var chartHeading: some View{
        HStack{
           
            
        }
    }
    
//    public func fetchDate(){
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy" //Specify your format that you want
//        var strDate = dateFormatter.string(from: NSDate(timeIntervalSince1970: Double(dataPrices.t.first!)) as Date)
//        Date().formatted(<#T##format: FormatStyle##FormatStyle#>)
//    }
    
    private var chartDate: some View{
        HStack{
            let startDate = (NSDate(timeIntervalSince1970: Double(dataPrices.t.first!)) as Date).formatted(.dateTime.day().month().year())
            
            Text("\(startDate)")
                .font(.system(size: 12)).foregroundColor(Color.black)
            Spacer()
            let endDate = (NSDate(timeIntervalSince1970: Double(dataPrices.t.last!)) as Date).formatted(.dateTime.day().month().year())
            Text("\(endDate)")
                .font(.system(size: 12)).foregroundColor(Color.black)
            
        }
    }
}

//GeometryReader { geometry in
//    Path { path in
//        for index in data.indices {
//            let Position = geometry.size.width / CGFloat (data.count)
//            CGFloat(index + 1)
//            let yAxis = maxY - minY
//            let Position = (1 - CGFloat ( (data[index] - minY) / yAxis)) *
//            geometry.size.height
//            if index == 0 {
//                path.move(to: CGPoint(x: Position, y: Position))
//            }
//            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
//        }
//        , stroke(lineColor, style: StrokeStyle(linewidth: 2, lineCap: .round,
//                                               lineJoin: ‚round))
//    }



/*{
 //        Text("Hello,sasa World!")
             
         List{
             Text("Hello,sasa World!").swipeActions {
                 Button("Burn") {
                     print("Right on!")
                 }
                 .tint(.red)
                 
             }
             Chart{
                 BarMark(x: .value("TESLA", "100"), y: .value("UBER", "120"))
             }
             Button {
                         Task {
                             let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.chucknorris.io/jokes/random")!)
                             let decodedResponse = try? JSONDecoder().decode(Joke.self, from: data)
                             print("Fetch Joke  \(String(describing: decodedResponse))")
 //                            var joke:Joke
 //                            joke = decodedResponse?.value ?? ""
                             
                         }
 //                Text("Fetch Joke  \(decodedResponse)")
                     } label: {
                         Text("Fetch Joke ")
                     }
             
         }
         .frame(height: 250)
     }
 */
