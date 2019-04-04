# Dockerfile

FROM node:10 as BUILD
COPY . .
RUN npm run build

FROM nginx:alpine
RUN apk add --no-cache bash
EXPOSE 80
COPY --from=BUILD dist /usr/share/nginx/html
