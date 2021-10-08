
Entropy(Alphabet, Length)
{
	; 0.30103 = log(2)
	return Ceil(log(Alphabet) / 0.30103 * Length)
	; https://en.wikipedia.org/wiki/Password_strength#Random_passwords
}
