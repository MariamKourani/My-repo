
#!/usr/bin/python
def alpha_combs(alphabet, n, acc='', res=[]):

    if n > 0:

        for c in alphabet:

            res.append(acc + c)

            alpha_combs(alphabet, n - 1, acc + c, res)

    return res

def result(s):

    bits = s.split()

    alphabet = bits[:-1]

    length = int(bits[-1])

    return alpha_combs(alphabet, length)


if __name__ == "__main__":

    f = open("organisingString.txt", "a");

    small_dataset = "O A R H Z G W P B L\n3"
    print ("\n".join(result(small_dataset)), file=f)
    f.close()