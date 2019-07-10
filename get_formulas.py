#!/usr/bin/env python
from contrib import dag
import sys, os, re, argparse

# Search for and add a node for every formula found in formula_dir that works with bottles
def buildDAG(args, formula_dir):
    formula_dag = dag.DAG()
    for formula_file in os.listdir(formula_dir):
        if formula_file.endswith(".rb"):
            formula_dag.add_node(os.path.basename(formula_file)[:-3])
    return buildEdges(args, formula_dir, formula_dag)

# Figure out what package depends on what other package
def buildEdges(args, formula_dir, dag_object):
    valid_formula = re.compile(r'bottle do')
    search_dep = re.compile(r'depends_on [\'\"](moose.*)[\'\"]')
    for node in dag_object.topological_sort():
        with open(os.path.join(formula_dir, node + ".rb"), 'r') as f:
            content = f.read()
        if valid_formula.findall(content):
            deps = search_dep.findall(content)
            for dep in deps:
                dag_object.add_edge(dep, node)
        elif not args.reverse:
            dag_object.delete_node(node)

    return dag_object

def verifyArgs(args):
    return args

def parseArguments(args=None):
    parser = argparse.ArgumentParser(description='Homebrew Formula dependency generator')
    parser.add_argument('-r', '--reverse', action='store_const', const=True, default=False, help='Reverse the dependency order')
    return verifyArgs(parser.parse_args(args))

if __name__ == "__main__":
    args = parseArguments()
    job_order = buildDAG(args, 'Formula')
    if args.reverse:
        reversed_clone = job_order.reverse_clone()
        print(' '.join(reversed_clone.topological_sort()))
        sys.exit(0)
    print(' '.join(job_order.topological_sort()))
