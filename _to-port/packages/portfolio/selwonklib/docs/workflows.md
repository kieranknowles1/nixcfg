# Workflows

Reusable templates for common GitHub workflows. Copy-paste them into a new
project and make changes where noted.

## astro-cloudflare

Deploy a static Astro site to Cloudflare Pages. Takes the following inputs:

<table>
  <thead>
    <th>Name</th>
    <th>Location</th>
    <th>Description</th>
  </thead>
  <tbody>
    <tr>
      <td><code>PROJECT_NAME</code></td>
      <td>Workflow</td>
      <td>
        Cloudflare Pages project name. The subdomain of `pages.dev` your site
        uses.
      </td>
    </tr>
    <tr>
      <td><code>CLOUDFLARE_API_TOKEN</code></td>
      <td>Repository secrets</td>
      <td>
        Cloudflare API token with <code>Cloudflare Pages:Edit</code> permissions.
      </td>
    </tr>
    <tr>
      <td><code>CLOUDFLARE_ACCOUNT_ID</code></td>
      <td>Repository secrets</td>
      <td>
        Your Cloudflare account ID. Found on the dashboard.
      </td>
    </tr>
  </tbody>
</table>
