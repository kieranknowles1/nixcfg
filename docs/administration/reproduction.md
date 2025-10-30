# Server Reproduction

Steps to reproduce a server based on this repository. Ideally NixOS would handle
**ALL** of this, but not everything is automated, and may never be.

See also: [Onboarding](./onboarding.md) for steps to introduce a new user.

## Paperless

Create a `users` group with the following permissions:

| Resource          | Permissions |
| ----------------- | ----------- |
| **Document**      | Full        |
| **Tag**           | Full        |
| **Correspondent** | Full        |
| **DocumentType**  | Full        |
| **StoragePath**   | None        |
| **SavedView**     | None        |
| **PaperlessTask** | View        |
| **AppConfig**     | None        |
| **UiSettings**    | Full        |
| **History**       | Add, View   |
| **Note**          | Full        |
| **MailAccount**   | None        |
| **MailRule**      | None        |
| **User**          | Voew        |
| **Group**         | View        |
| **ShareLink**     | Full        |
| **CustomField**   | Full        |
| **Workflow**      | View        |

Create an **Inbox** tag with no matching and visible to the `users` group.
