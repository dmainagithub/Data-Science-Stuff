// import delimited "$mypath\$myfile.csv", bindquote(strict) varnames(1) stripquote(yes)

clear all
cd "$mypath"

import delimited "$mypath\$myfile.csv", ///
    bindquote(strict) varnames(1) stripquote(yes)
