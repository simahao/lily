from . import Connection


def get_buglist(**config):
   conn = Connection(**config) 
   result = conn.querydb("")
   return result


def new_issue(**config):


