function W=define_pcbc_feedforward_weights(V)
%for PCBC also need to define a set of feedforward (descriminative) weights
W=norm_dictionary(V,1);%feedforward weights equal to feedback weights normalized by sum
