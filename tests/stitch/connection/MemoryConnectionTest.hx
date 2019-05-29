package stitch.connection;

class MemoryConnectionTest extends ConnectionTest {

  public function new() {
    super(() -> new MemoryConnection([
      'flat' => [
        'a.json' => '{"title":"a","value":"a"}',
        'b.json' => '{"title":"b","value":"b"}'
      ],
      'pages/a' => '
title: a
---
value: a',
      'pages/b' => '
title: b
---
value: b'
    ]));
  }

}
