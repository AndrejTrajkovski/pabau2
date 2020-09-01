import UIKit

func makeIntervals(minuteInterval: Int) -> [Interval] {
	let intervalsPerHour = 60 / minuteInterval
	var result = [Interval]()
	for hourIdx in 0...23 {
		for minuteIdx in 0..<intervalsPerHour {
			let minuteFrom = minuteIdx * minuteInterval
			let minuteTo = (minuteIdx + 1) * minuteInterval
			result.append(Interval(hourIndex: hourIdx,
														 minuteFrom: minuteFrom,
														 minuteTo: minuteTo)
			)
		}
	}
	return result
}

struct Interval {
	let hourIndex: Int//00-23
	let minuteFrom: Int
	let minuteTo: Int
}
