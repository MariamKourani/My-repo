import random
import time

def generate_string(N, alphabet = 'ACTG'):
    # make a random list of N number of nucleotides:
    return ''.join([random.choice(alphabet) for i in range(N)]);
#measuring CPU time
t0 = time.clock();
dna = generate_string(20);  
print(dna);
t1 = time.clock();
cpu_time = t1-t0;
print(cpu_time);