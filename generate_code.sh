java -jar tools/openapi-generator-cli-7.5.0.jar generate -g dart -i api.yaml -o openapi

cd openapi

dart pub get

cd ../flutter_application

dart run build_runner build --delete-conflicting-outputs

cd ../server_application

dart pub get

cd ..