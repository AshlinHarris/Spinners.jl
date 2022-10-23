using Replay
repl_script = """
using Spinners
@spinner "🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛" 0.1 sleep(5)
"""
replay(repl_script, stdout, use_ghostwriter=true, cmd="--color=yes --quiet", julia_project=@__DIR__)
