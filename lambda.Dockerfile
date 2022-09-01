FROM rust:1.63-alpine3.16 as builder
RUN rustup component add clippy rustfmt
RUN apk add --no-cache musl-dev zip
WORKDIR /usr/src/sqlpage
RUN cargo init .
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release
COPY . .
RUN cargo build --release --features lambda-web
RUN   mv target/release/sqlpage bootstrap && \
      strip --strip-all bootstrap && \
      size bootstrap && \
      ldd  bootstrap && \
      zip -9 -r deploy.zip bootstrap index.sql documentation.sql sqlpage

FROM public.ecr.aws/lambda/provided:al2 as runner
COPY --from=builder /usr/src/sqlpage/bootstrap /main
ENTRYPOINT ["/main"]