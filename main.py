def divide(a) :
	one_third =(( a * 1_000_000_000_000) // 3)
	two_thirds  = one_third *2
	three_thirds  = one_third *3

	print(one_third)
	print(two_thirds)
	print(three_thirds+1)


if __name__ == "__main__":
	divide(4)