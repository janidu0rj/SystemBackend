# Stage 1: Build the Flutter web app
FROM dart:stable as build

WORKDIR /app

#Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter --version

#Copy your Flutter app code
COPY . .

#Get dependencies and build for web
RUN flutter pub get
RUN flutter build web

#Stage 2: Serve with nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

#Custom nginx config for SPA support
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

## Stage 1: Use official Flutter image
#FROM cirrusci/flutter:stable-web AS build
#
#WORKDIR /app
#
## Cache dependencies
#COPY pubspec.* ./
#RUN flutter pub get
#
## Copy the rest of the code
#COPY . .
#
## Build for web (only code changes will trigger this)
#RUN flutter build web
#
## Stage 2: Serve with nginx
#FROM nginx:alpine
#COPY --from=build /app/build/web /usr/share/nginx/html
#
## Custom nginx config for SPA support
#RUN rm /etc/nginx/conf.d/default.conf
#COPY nginx.conf /etc/nginx/conf.d
#
#EXPOSE 80
#
#CMD ["nginx", "-g", "daemon off;"]
#
