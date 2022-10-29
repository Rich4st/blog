FROM node:18-alpine3.15

WORKDIR /blog

COPY .output .

EXPOSE 3000

CMD [ "node", "./server/index.mjs" ]
