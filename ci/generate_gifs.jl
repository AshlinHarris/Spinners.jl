using Replay
repl_script = """
using Spinners
@spinner :earth 0.1 sleep(5)
"""
replay(repl_script, stdout, use_ghostwriter=true, cmd="--color=yes", julia_project=@__DIR__)
