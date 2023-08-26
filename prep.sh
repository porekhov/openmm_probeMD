if [ $# -ne 1 ]; then
  echo "Usage: $0 protein.pdb"
  exit 1
fi

pdb_in=$1

### PREPARING THE SYSTEM ###

# proceed the input pdb with pdbfixer to resolve possible 
pdbfixer $pdb_in --add-atoms heavy --replace-nonstandard --add-residues --keep-heterogens=none --output=aa_fixed.pdb

# get secondary structure using DSSP from MDtraj
ss=$(python dssp.py aa_fixed.pdb)
# martinize the system
martinize2 -maxwarn 100 -f aa_fixed.pdb -x _cg.pdb -o _topol.top -scfix -cys auto  -elastic -p backbone -ss $ss -nt -merge A,B,C,D,E,F,G,H,I
# add water and probe molecules
python insane_probes.py -f _cg.pdb -o _cg_sol.gro -p _insane.top -salt 0 -charge auto -sol W:0.952 -sol PHEN:0.003 -sol ACET:0.009 -sol IPA:0.009 -sol DMAD:0.009 -sol IPO:0.009 -sol PPN:0.009 -pbc cubic -d 3.0

sed -n -E '/^(CLBZ|PHEN|BENZ|ACE|IPA|DMAD|IPO|PPN|W)/p' _insane.top >> topol.top
