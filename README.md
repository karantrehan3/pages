# pages

Public pages served by GitHub Pages at **https://karantrehan3.github.io/pages/**.

- Each page lives at `<slug>/index.html` → `https://karantrehan3.github.io/pages/<slug>/`
- The site root redirects to the **default** page.

## Usage

```bash
scripts/page.sh add ~/Downloads/thing.html my-thing   # add / replace a page
scripts/page.sh default my-thing                      # make it the root page
scripts/page.sh list                                  # list pages (default marked)
scripts/page.sh remove old-thing                      # delete a page
git add -A && git commit -m "feat: add my-thing" && git push
```

Pages are live ~1 minute after pushing. Everything here is **public**.
