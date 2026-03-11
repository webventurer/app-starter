import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();

app.use("/*", cors());

// Mount route modules here
// app.route("/api/users", usersRoute);

serve({ fetch: app.fetch, port: 3001 });
