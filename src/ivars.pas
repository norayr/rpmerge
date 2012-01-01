unit ivars;

interface

var DistDir, BuildDir, RpmBuildCommand, CompilerFlags, ForceCompilerFlags, OptimizationLevel, PkgConfigPath,
    BunzipFlags, patet, SourcesDataFile : string;
    m, urls : array of string;
    questions, compiled, al, force, CompileOnly, DownloadOnly : boolean;
ii, jj : integer;
    verbose : boolean;

implementation

begin
verbose := true;
end.	
