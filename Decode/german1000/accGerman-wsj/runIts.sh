
#########################################
# Acoustic Model Adaptation for Sphinx-3
# spalkar@
# October 2012
#########################################

# Add the following paths to your bashrc
# These point to Sphinx-3 and SphinTrain 
# installations in my directory.

export PATH=/home/spalkar/bin:$PATH
export PATH=/home/spalkar/decode/bin:$PATH
export PATH=/home/spalkar/retrain:$PATH
export PATH=/home/spalkar/retrain/bin:$PATH
export LD_LIBRARY_PATH=/home/spalkar/retrain/lib/

# Assumes you have the following setup:
# (via the perl scripts_pl/copy_setup.pl -task <name>)
# - SphinxTrain folder XYZ setup via copy_setup.pl
# - etc/XYZ_train.fileids which has a list of fileids
# - etc/wav/ has the audio files
# - etc/sphinx_train.cfg has the correct values
# - feat.params is present in the XYZ folder with actual values

# Base decoding config

#base_cfg="/home/ssitaram/s2slab/german-wsj.cfg";
#base_hyp="/home/ssitaram/s2slab/hyp/german1000-wsj.hyp";
base_cfg="/home2/jchiu1/TTS_notext/cfg/german-wsj.cfg";
base_hyp="/home2/jchiu1/TTS_notext/hyp/german1000-wsj.hyp";



# AM Adaptation Config

# the name of the sphinxtrain folder
ret_name="accGerman-wsj";
#ret_path="/home/ssitaram/s2slab/german1000";
ret_path="/home2/jchiu1/TTS_notext/Decode/german1000";

#path to directory with config files for Sphinx decoding
#dec_cfg_name="/home/ssitaram/s2slab/german-wsj-myacc.cfg";
#dec_hyp_name="/home/ssitaram/s2slab/hyp/german1000-wsj-myacc.hyp";
dec_cfg_name="/home2/jchiu1/TTS_notext/cfg/german-wsj-myacc.cfg";
dec_hyp_name="/home2/jchiu1/TTS_notext/hyp/german1000-wsj-myacc.hyp";


# base decoding with ready AM of your choice
sphinx3_decode $base_cfg;
cp $base_hyp $ret_path/$ret_name/etc/$ret_name"_train.transcription";
python getPhoneset.py $ret_path/$ret_name/etc/$ret_name"_train.transcription" $ret_path/$ret_name/etc/$ret_name;

# this directory to store the intermediate acoustic models
mkdir "models";
#perl scripts_pl/make_feats.pl -ctl etc/$ret_name"_train.fileids";

for i in $(seq 1 10);
do 
	#acoustic model training
	j=$((i-1));
	perl scripts_pl/RunAll.pl;
	mv etc/$ret_name"_train.transcription" etc/$ret_name"_train.transcription.it"$j;
	cp model_architecture/$ret_name".1000.mdef" model_parameters/$ret_name".cd_cont_1000_8/mdef";
	cp feat.params model_parameters/$ret_name".cd_cont_1000_8/";
	#decoding with new model
	#cd $dec_dir;
	sphinx3_decode $dec_cfg_name;

	#setting up next round
	cp $dec_hyp_name $dec_hyp_name".it"$i;
	cp $dec_hyp_name $ret_path/$ret_name/etc/$ret_name"_train.transcription";
	python getPhoneset.py $ret_path/$ret_name/etc/$ret_name"_train.transcription" $ret_path/$ret_name/etc/$ret_name;

	#cd $ret_path;
	cp -r model_parameters/$ret_name".cd_cont_1000_8/" models/$ret_name".cd_cont_1000_8_it"$j;
done
