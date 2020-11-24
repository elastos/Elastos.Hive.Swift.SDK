wget https://github.com/elastos/Elastos.NET.Hive.Swift.SDK/releases/download/alpha-v2.01/Antlr4.framework.zip;
tar -xzf Antlr4.framework.zip;

cd ElastosHiveSDKTests
mkdir Externals
cd ..
mv Antlr4.framework ElastosHiveSDKTests/Externals/Antlr4.framework

find . | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"

