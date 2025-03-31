extends Node

static func binomial(tries : float, prob : float) -> float:
	return abs(randfn(tries*prob,tries*prob*(1.0-prob)))

#1 or 0
func bernoulli(prob : float) -> int:
	return int(randf() < prob)
