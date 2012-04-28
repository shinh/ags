# FerNANDo Interpreter
# Runs fernando programs, used command line style.
# Author: Orange
# Editors: Stop h time, Oerjan, Primo
# Version 0.5

# You're free to use this code as you wish

class varfunc(object):
    def __init__(self, func): self._func = func
    __and__     = lambda self, other: self._func() & other
    __rand__    = lambda self, other: other & self._func()
    __add__     = lambda self, other: self._func() + other
    __radd__    = lambda self, other: other + self._func()
    __nonzero__ = lambda self: bool(self._func())

def FerNANDo(program, no_prng=False):
    ''' Run a FerNANDo program '''

    #Split the program into a sequence of lines
    p = program.split('\n')

    #Split each line into variables
    p = map(lambda a: a.split(), p)

    pc = 0         #program counter
    plen = len(p)  #program length

    var = {}  #variable look-up table
    if not no_prng:
        var['?'] = varfunc(lambda: random.randint(0, 1))  #PRNG

    while pc < plen:
        #Current line
        line = p[pc]

        #See how many variables on a line
        #If 1, 2, 3, 8, or 9, execute a command
        #Check in order of likelihood
        count = len(line)
        if count == 3 or count == 2:  #NAND
            #bitwise & instead of 'and' is necessary
            #to prevent varfuncs from evaluating twice
            var[line[0]] = not (var.get(line[-2], 0) & var.get(line[-1], 0))
        elif count == 8:  #Output
            ascii = 0
            for item in line:
                #Double the value (<<1) and add the next bit
                ascii += ascii + var.get(item, 0)
            sys.stdout.write(chr(ascii))
        elif count == 1:  #Jump
            #Var is set and has occurred previously
            if bool(var.get(line[0], 0)) and (line in p[:pc]):
                #Find the previous occurrence
                pc -= p[:pc][::-1].index(line) + 1
        elif count == 9:  #Read
            char = sys.stdin.read(1)
            if char:
                var[line[0]] = 1
                ascii = ord(char)
                shift = 7
                for item in line[1:]:
                    var[item] = (ascii >> shift) & 1
                    shift -= 1
            else:
                var[line[0]] = 0
        elif count==0:  #Empty
            pass
        else:
            sys.stderr.write('Error: Undefined sentence on line %d: '%(pc+1) + ' '.join(line))
            sys.exit(1)
        pc += 1

import sys, random, argparse

try:
    parser = argparse.ArgumentParser(description='Run a FerNANDo program')
    parser.add_argument('progname', metavar='progtorun.nand', type=str,
        help='the filename of the FerNANDo program to run')
    parser.add_argument('--no-prng', dest='no_prng', action='store_true',
        help="disable the PRNG bit variable '?' (leave it unset)")
    args = parser.parse_args()
    
    f = open(args.progname)
    prog = f.read()
    f.close()
    FerNANDo(prog, args.no_prng)
except IOError:
    sys.stderr.write("Error: Can't open file '%s'"%args.progname)
    sys.exit(1)
