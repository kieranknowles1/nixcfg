# Magic Behavior

Certain "magic" behavior is implemented to enhance user experience and is
documented here.

## Files

<table>
  <tr>
    <th>File</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>~/.config/default-shell</code></td>
    <td>
      A symlink to the user's <code>$SHELL</code><br>
      Used to reliably switch to it in dev shells.<br>
      Set in [`users.nix`](../../modules/nixos/users.nix)
    </td>
  </tr>
</table>
