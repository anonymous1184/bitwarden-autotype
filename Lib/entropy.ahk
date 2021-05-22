
entropy(alphabet, length)
{
    ; 0.30103 = log(2)
    return Ceil(log(alphabet) / 0.30103 * length)
    ; https://en.wikipedia.org/wiki/Password_strength#Random_passwords
}
