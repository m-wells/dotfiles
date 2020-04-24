using LanguageServer
using LanguageServer.SymbolServer
using LanguageServer.StaticLint

using Pkg
env_path = dirname(Pkg.Types.Context().env.project_file)

debug = false
server = LanguageServer.LanguageServerInstance(stdin, stdout, debug, env_path)
server.runlinter = true
run(server)
