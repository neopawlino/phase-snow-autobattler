extends Node

static func binomial(tries : float, prob : float) -> float:
	if tries < 100:
		var acc : int = 0
		for i in range(0,tries):
			acc += bernoulli(prob)
		return float(acc)
	else:
		return abs(randfn(tries*prob,tries*prob*(1.0-prob)))

#1 or 0
static func bernoulli(prob : float) -> int:
	return int(randf() < prob)
