# Deploy and Host Zammad 7 on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/zammad-7?utm_medium=integration&utm_source=button&utm_campaign=zammad-7)

[Zammad](https://zammad.org/) is the open-source helpdesk and ticketing system: email, web forms, chat, phone, WhatsApp, Telegram and social channels land in one shared inbox, with SLAs, triggers, a knowledge base and reporting on top. This template runs Zammad 7.2 with Elasticsearch for full-text search, and creates your admin account on first boot, so the setup wizard is never open to whoever finds the URL first.

## About Hosting Zammad 7

The stack is four services: Zammad, Elasticsearch, Postgres and Redis.

- **Every Zammad process in one service.** nginx on the public port, the Rails server, the websocket server and the background workers run together, like a package install on a server. Upstream's compose splits them into five containers that each boot Rails to wait for an init container; here there is one deploy to watch and one set of logs.
- **Admin ready, setup page closed.** The first boot installs the database, runs Zammad's own auto wizard with your email and a generated password, and names the organization. Log in and start working.
- **Search that finds things.** Elasticsearch 9 indexes tickets, articles, attachments, users and organizations. The index is built on first boot and rebuilt automatically if it's ever missing.
- **Upgrades that migrate themselves.** Every boot runs Zammad's migrations and translation sync before serving, so bumping the image tag is the whole upgrade.
- **Private by default.** Only nginx has a public address. Postgres, Redis and Elasticsearch are on the private network, and Elasticsearch requires a password anyway.

## Common Use Cases

- A shared support inbox for a small team, with assignment, SLAs and customer history
- An IT or internal helpdesk with a knowledge base employees can search
- Replacing Zendesk or Freshdesk with a self-hosted system and no per-agent fees

## Dependencies for Zammad 7 Hosting

- Elasticsearch 9.5 (included, private network only)
- Postgres 17 (included, private network only)
- Redis 8 (included, private network only)

### Deployment Dependencies

- [Zammad admin documentation](https://admin-docs.zammad.org/)
- [Zammad user documentation](https://user-docs.zammad.org/)
- [Template source on GitHub](https://github.com/nomideusz/zammad-railway)

### Implementation Details

**Sign in** at the Zammad service's Railway domain with the email you entered at deploy time and the `ZAMMAD_ADMIN_PASSWORD` value from the Zammad service's Variables tab. The first boot creates the database and the search index, so give it three or four minutes. Change the password afterwards under Profile → Password; the variable is only read on first boot.

**Email.** Receiving mail over IMAP or POP3 works on every plan. Sending is where plans differ: Railway only allows outbound SMTP on the Pro plan. On other plans, connect a Microsoft 365 mailbox under Channels → Microsoft 365 Graph Email, which sends and receives over Microsoft's HTTPS API instead of SMTP. Any other mailbox sends over SMTP, which needs Pro.

**Memory.** Around 2.3 GB at idle: about 1 GB for Zammad (Rails server, websocket server, background workers), 1.2 GB for Elasticsearch with its 512 MB heap, and 130 MB for Postgres. Deploy on Hobby or above. For large ticket volumes raise `ES_JAVA_OPTS` on the Elasticsearch service, for example to `-Xms1g -Xmx1g`.

**Attachments and backups.** Zammad keeps tickets and attachments in Postgres by default, so the Postgres volume holds everything that matters; enable Railway's volume backups on it. Leave the attachment storage setting on Database: the Zammad service's own disk is not persistent. The search index can always be rebuilt from Postgres with `bundle exec rake zammad:searchindex:rebuild` in a `railway ssh` session on the Zammad service.

**Custom domain.** Add it in the Zammad service's Settings → Networking, then set `ZAMMAD_FQDN` to the bare domain (`help.example.com`). Zammad picks it up on the next boot and uses it in links and emails.

## Why Deploy Zammad 7 on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Zammad 7 on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
