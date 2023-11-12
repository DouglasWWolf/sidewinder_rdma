dest=bitstream

mkdir $dest 2>/dev/null


cp sidewinder.runs/impl_1/design_1_wrapper.bit ${dest}/sidewinder_rdma.bit
cp sidewinder.runs/impl_1/design_1_wrapper.ltx ${dest}/sidewinder_rdma.ltx

