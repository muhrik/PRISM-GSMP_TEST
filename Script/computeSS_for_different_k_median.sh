#compute steady state probabilities for various k values.
#This script must remain in CZK_project/Script !!!
#There is only one parameter - floating point number specifying the timeout.
#Lambda is derived as (ln 2 / timeout).

PRISM_PATH_FROM_SCRIPT="../../../../prismGSMP/prism-gsmp/prism/bin"
MODEL_PATH_FROM_PRISM="../../../../CZK_project/Model"
OUTPUT_PATH_FROM_PRISM="../../../../CZK_project/Output"

lambda=$(bc <<< "scale=10;0.693147181/$1")
esp="1E-5"
esp_precise="1E-8"

reNum='^[-+]?[0-9]+\.?[0-9]*$'
if ! [[ $1 =~ $reNum ]]; then
  echo "Please specify number \"timeout\" as the first parameter!"
  exit 1
fi

cd '../Output'

mkdir "t=$1_median"
cd "t=$1_median"
mkdir "explicit"
cd "explicit"

cd $PRISM_PATH_FROM_SCRIPT
#compute explicit phase type
for k in 1 2 5 10 25 50 75 100 125 150 175 200 225 250 275 300 500 1000 2000 3000 4000 5000
do
	echo explicit $k $esp
  ./prism -explicit -epsilon ${esp} -maxiters 100000000 -power -absolute -const k=$k,timeout=$1,lambda=$lambda "$MODEL_PATH_FROM_PRISM/queue_withptf_gsmp.sm" -ss -exportss "$OUTPUT_PATH_FROM_PRISM/t=$1_median/explicit/ph_10_${k}_${esp}" > "$OUTPUT_PATH_FROM_PRISM/t=$1_median/explicit/ph_10_${k}_${esp}.log"
done

#compute explicit event
echo event k $esp_precise
./prism -explicit -epsilon ${esp_precise} -maxiters 100000000 -power -absolute -const timeout=$1,lambda=$lambda "$MODEL_PATH_FROM_PRISM/timeoutqueue.sm" -ss -exportss "$OUTPUT_PATH_FROM_PRISM/t=$1_median/explicit/ev_10_k_${esp_precise}" > "$OUTPUT_PATH_FROM_PRISM/t=$1_median/explicit/ev_10_k_${esp_precise}.log"
echo event k $esp_precise
./prism -explicit -epsilon ${esp} -maxiters 100000000 -power -absolute -const timeout=$1,lambda=$lambda "$MODEL_PATH_FROM_PRISM/timeoutqueue.sm" -ss -exportss "$OUTPUT_PATH_FROM_PRISM/t=$1_median/explicit/ev_10_k_${esp}" > "$OUTPUT_PATH_FROM_PRISM/t=$1_median/explicit/ev_10_k_${esp}.log"
cd -

#write a readme file for explicit computations
touch readme.txt
echo "t=$1" >> readme.txt
echo "lambda=ln(2)/timeout" >> readme.txt
echo "n=10" >> readme.txt
echo "naming: ev/ph_n_k_epsilon" >> readme.txt
echo "steady state distributions using the GSMP (ctmc with phase type) explicit engine
for termination epsilon 1.0E-5 for phase type, and termination epsilon 1.0E-8 and 1.0E-6 for event. 
For each computation a full log file is also created with the extention .log" >> readme.txt

cd "../"
mkdir "hybrid"
cd "hybrid"

cd $PRISM_PATH_FROM_SCRIPT
#compute hybrid phase type
for k in 1 2 5 10 25 50 75 100 125 150 175 200 225 250 275 300 500 1000 2000 3000 4000 5000
do
	echo hybrid $k $esp
  ./prism -hybrid -epsilon ${esp} -maxiters 100000000 -power -absolute -const k=$k,timeout=$1,lambda=$lambda "$MODEL_PATH_FROM_PRISM/queue_withptf_ctmc.sm" -ss -exportss "$OUTPUT_PATH_FROM_PRISM/t=$1_median/hybrid/ph_10_${k}_${esp}" > "$OUTPUT_PATH_FROM_PRISM/t=$1_median/hybrid/ph_10_${k}_${esp}.log"
done
cd -

#write a readme file for hybrid computations
touch readme.txt
echo "t=$1" >> readme.txt
echo "lambda=ln(2)/timeout" >> readme.txt
echo "n=10" >> readme.txt
echo "naming: ph_n_k_epsilon" >> readme.txt
echo "steady state distributions using the CTMC with phase type on hybrid engine with Power method
absolute termination criteria for termination epsilon 1.0E-5 for phase type." >> readme.txt

