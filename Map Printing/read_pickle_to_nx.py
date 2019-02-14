import networkx as nx
import pickle

def read_file(filename):
    G = nx.read_gpickle(filename)
    return G
