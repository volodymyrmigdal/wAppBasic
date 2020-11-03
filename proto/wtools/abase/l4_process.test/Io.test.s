( function _Io_test_s( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( './../../../wtools/Tools.s' );
  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wProcessWatcher' );

  require( '../l4_process/Basic.s' );

}

let _global = _global_;
let _ = _global_.wTools;
let Self = {};

// --
// context
// --

function suiteBegin()
{
  let context = this;
  console.log( _.path.dirTemp() )
  context.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'Io' );
  context.assetsOriginalPath = _.path.join( __dirname, '_asset' );
  context.appJsPath = _.path.nativize( _.module.resolve( 'wProcess' ) );
  console.log( 'suiteBegin:', context.suiteTempPath );
}

//

function suiteEnd()
{
  let context = this;
  console.log( 'suiteEnd:', context.suiteTempPath );
  _.assert( _.strHas( context.suiteTempPath, '/Io' ), `context.suiteTempPath : ${context.suiteTempPath}` );
  _.path.tempClose( context.suiteTempPath );
}

// --
// event
// --

function processOnExitEvent( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.path.nativize( a.program( testApp ) );  /* zzz : a.path.nativize? */
  // let programPath = a.program( testApp );

  /* */

  a.ready.then( () =>
  {
    var o =
    {
      execPath :  'node ' + programPath,
      mode : 'spawn',
      stdio : 'pipe',
      sync : 0,
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( op ) =>
    {
      test.is( op.exitCode === 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'timeOut handler executed' ) )
      test.is( _.strHas( op.output, 'processOnExit: 0' ) );
      return null;
    })

  })

  /* */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + programPath + ' terminate : 1',
      mode : 'spawn',
      stdio : 'pipe',
      sync : 0,
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( op ) =>
    {
      test.is( op.exitCode === 0 );
      test.identical( op.ended, true );
      test.is( !_.strHas( op.output, 'timeOut handler executed' ) )
      test.is( !_.strHas( op.output, 'processOnExit: 0' ) );
      test.is( _.strHas( op.output, 'processOnExit: SIGINT' ) );
      return null;
    });
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )

    var args = _.process.input();

    _.process.on( 'exit', ( arg ) =>
    {
      console.log( 'processOnExit:', arg );
    });

    _.time.out( 1000, () =>
    {
      console.log( 'timeOut handler executed' );
      return 1;
    })

    if( args.map.terminate )
    process.exit( 'SIGINT' );

  }
}

//

function processOffExitEvent( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.path.nativize( a.program( testApp ) );

  /* */

  a.ready.then( () =>
  {
    test.case = 'nothing to off'
    var o =
    {
      execPath :  'node ' + programPath,
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( _.strCount( op.output, 'timeOut handler executed'  ), 1 );
      test.identical( _.strCount( op.output, 'processOnExit1: 0' ), 1 );
      test.identical( _.strCount( op.output, 'processOnExit2: 0' ), 1 );
      test.identical( _.strCount( op.output, 'processOnExit3: 0' ), 0 );
      return null;
    })

  })

  /* */

  .then( () =>
  {
    test.case = 'off single handler'
    var o =
    {
      execPath :  'node ' + programPath,
      args : 'off:handler1',
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( _.strCount( op.output, 'timeOut handler executed'  ), 1 );
      test.identical( _.strCount( op.output, 'processOnExit1: 0' ), 0 );
      test.identical( _.strCount( op.output, 'processOnExit2: 0' ), 1 );
      test.identical( _.strCount( op.output, 'processOnExit3: 0' ), 0 );
      return null;
    })
  })

  /* */

  .then( () =>
  {
    test.case = 'off all handlers'
    var o =
    {
      execPath :  'node ' + programPath,
      args : 'off:[handler1,handler2]',
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( _.strCount( op.output, 'timeOut handler executed'  ), 1 );
      test.identical( _.strCount( op.output, 'processOnExit1: 0' ), 0 );
      test.identical( _.strCount( op.output, 'processOnExit2: 0' ), 0 );
      test.identical( _.strCount( op.output, 'processOnExit3: 0' ), 0 );
      return null;
    })
  })

  /* */

  .then( () =>
  {
    test.case = 'off unregistered handler'
    var o =
    {
      execPath :  'node ' + programPath,
      args : 'off:handler3',
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    return _.process.start( o )
    .then( ( op ) =>
    {
      test.notIdentical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( _.strCount( op.output, 'uncaught error' ), 2 );
      test.identical( _.strCount( op.output, 'processOnExit1: -1' ), 1 );
      test.identical( _.strCount( op.output, 'processOnExit2: -1' ), 1 );
      test.identical( _.strCount( op.output, 'processOnExit3: -1' ), 0 );
      return null;
    })
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )

    var handlersMap = {};
    var args = _.process.input();

    handlersMap[ 'handler1' ] = handler1;
    handlersMap[ 'handler2' ] = handler2;
    handlersMap[ 'handler3' ] = handler3;

    _.process.on( 'exit', handler1 );
    _.process.on( 'exit', handler2 );

    if( args.map.off )
    {
      args.map.off = _.arrayAs( args.map.off );
      _.each( args.map.off, ( name ) =>
      {
        _.assert( handlersMap[ name ] );
        _.process.off( 'exit', handlersMap[ name ] );
      })
    }

    _.time.out( 1000, () =>
    {
      console.log( 'timeOut handler executed' );
      return 1;
    })

    function handler1( arg )
    {
      console.log( 'processOnExit1:', arg );
    }
    function handler2( arg )
    {
      console.log( 'processOnExit2:', arg );
    }
    function handler3( arg )
    {
      console.log( 'processOnExit3:', arg );
    }
  }
}

// --
// args
// --

function processArgsBase( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.path.nativize( a.program( testApp ) );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })

  let filePath = a.abs( 'got' );
  let interpreterPath = a.path.normalize( process.argv[ 0 ] );
  let scriptPath = a.path.normalize( programPath );

  /* */

  shell({ args : [] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got =   a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      subject : '',
      map : Object.create( null ),
      scriptArgs : [],
      scriptArgsString : '',
      subjects : [],
      maps : [],
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell({ args : [ '' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      subject : '',
      map : Object.create( null ),
      scriptArgs : [ '' ],
      scriptArgsString : '',
      subjects : [],
      maps : [],
    }
    test.contains( got, expected );
    return null;
  })


  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.input({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//


function processArgsPropertiesBase( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.path.nativize( a.program( testApp ) );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })
  let filePath = a.abs( 'got' );
  let interpreterPath = a.path.normalize( process.argv[ 0 ] );
  let scriptPath = a.path.normalize( programPath );

  /* */

  shell({ args : [ 'x', ':', 'aa', 'bbb', ':', 'x' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { x : 'aa', bbb : 'x' },
      subject : '',
      scriptArgs : [ 'x', ':', 'aa', 'bbb', ':', 'x' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell({ args : [ 'x', ':', 'y' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { x : 'y' },
      subject : '',
      scriptArgs : [ 'x', ':', 'y' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell({ args : [ 'x', ':', 'y', 'x', ':', '1' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { x : [ 'y', 1 ] },
      subject : '',
      scriptArgs : [ 'x', ':', 'y', 'x', ':', '1' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell({ args : [ 'abcd', 'x', ':', 'y', 'xyz', 'y', ':', 1  ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { x : 'y xyz', y : 1 },
      subject : 'abcd',
      scriptArgs : [ 'abcd', 'x', ':', 'y', 'xyz', 'y', ':', '1' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell
  ({
    args :
    [
      'filePath',
      'a:', 1,
      'b', ':2',
      'c:', 3,
      'd', ':4',
      'e', ':', 5
    ]
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { a : 1, b : 2, c : 3, d : 4, e : 5 },
      subject : 'filePath',
      scriptArgs :
      [
        'filePath',
        'a:', '1',
        'b', ':2',
        'c:', '3',
        'd', ':4',
        'e', ':', '5'
      ]
    }
    test.contains( got, expected );
    return null;
  })

  shell({ args : [ 'path:c:\\some', 'x', ':', 0, 'y', ':', 1 ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { path : 'c:\\some', x : 0, y : 1 },
      subject : '',
      scriptArgs : [ 'path:c:\\some', 'x', ':', '0', 'y', ':', '1' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    return null;
  })
  shell
  ({
    args : [ 'interpreter', 'main.js', 'v:"10"' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '',
      map : { v : 10 },
      scriptArgs : [ 'v:"10"' ],
      scriptArgsString : 'v:"10"',
      subjects : [ '' ],
      maps : [ { v : 10 } ],
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    return null;
  })
  shell
  ({
    args : [ 'interpreter', 'main.js', 'str:"abc"' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '',
      map : { str : 'abc' },
      scriptArgs : [ 'str:"abc"' ],
      scriptArgsString : 'str:"abc"',
      subjects : [ '' ],
      maps : [ { str : 'abc' } ],
    }
    test.contains( got, expected );
    return null;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.input({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//

function processArgsMultipleCommands( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.path.nativize( a.program( testApp ) );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })

  let filePath = a.abs( 'got' );

  /* */

  shell
  ({
    args : [ 'interpreter', 'main.js', '.set', 'v:5', ';', '.build', 'debug:1', ';', '.export' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH },
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '.set',
      map : { v : 5 },
      scriptArgs : [ '.set', 'v:5', ';', '.build', 'debug:1', ';', '.export' ],
      scriptArgsString : '.set v:5 ; .build debug:1 ; .export',
      subjects : [ '.set', '.build', '.export' ],
      maps : [ { v : 5 }, { debug : 1 }, {} ],
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell
  ({
    args : [ 'interpreter', 'main.js', '.set', 'v', ':', '[', 1, 2, 3, ']', ';', '.build', 'debug:1', ';', '.export' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '.set',
      map : { v : [ 1, 2, 3 ] },
      scriptArgs : [ '.set', 'v', ':', '[', '1', '2', '3', ']', ';', '.build', 'debug:1', ';', '.export' ],
      scriptArgsString : '.set v : [ 1 2 3 ] ; .build debug:1 ; .export',
      subjects : [ '.set', '.build', '.export' ],
      maps : [ { v : [ 1, 2, 3 ] }, { debug : 1 }, {} ],
    }
    test.contains( got, expected );
    return null;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.input({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//

function processArgsPaths( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.path.nativize( a.program( testApp ) );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })

  let filePath = a.abs( 'got' );

  /* */

  shell
  ({
    args : [ 'interpreter', 'main.js', 'path:D:\\path\\to\\file' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '',
      map : { path : 'D:\\path\\to\\file' },
      scriptArgs : [ 'path:D:\\path\\to\\file' ],
      scriptArgsString : 'path:D:\\path\\to\\file',
      subjects : [ '' ],
      maps : [ { path : 'D:\\path\\to\\file' } ],
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell
  ({
    args : [ 'interpreter', 'main.js', 'path:"D:\\path\\to\\file"' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '',
      map : { path : 'D:\\path\\to\\file' },
      scriptArgs : [ 'path:"D:\\path\\to\\file"' ],
      scriptArgsString : 'path:"D:\\path\\to\\file"',
      subjects : [ '' ],
      maps : [ { path : 'D:\\path\\to\\file' } ],
    }
    test.contains( got, expected );
    return null;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.input({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//

function processArgsWithSpace( test ) /* qqq : split test cases | aaa : Done. Yevhen S. */
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.path.nativize( a.program( testApp ) );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })

  let filePath = a.abs( 'got' );

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is quoted and contains space'
    return null;
  })
  shell( `subject option:"value with space"` )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option:"value with space"' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option:"value with space"',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option:"value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is quoted and contains space'
    return null;
  })
  shell( `subject option:'value with space'` )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', `option:'value with space'` ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : `subject option:'value with space'`,
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : `subject option:'value with space'`
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is quoted and contains space'
    return null;
  })
  shell( 'subject option:`value with space`' )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option:`value with space`' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option:`value with space`',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option:`value with space`'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    test.description = 'subject + option, option value is quoted and contains space'
    test.will = 'process.input should quote arguments with space'
    return null;
  })
  shell( `subject option : "value with space"` )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option', ':', 'value with space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option : "value with space"',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value contains space'
    return null;
  })
  shell({ args : [ 'subject', 'option', ':', 'value with space' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option', ':', 'value with space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option : "value with space"',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is quoted and contains space'
    return null;
  })
  shell({ args : [ 'subject', 'option', ':', '"value with space"' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option', ':', '"value with space"' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option : "value with space"',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is not quoted and contains space'
    return null;
  })
  shell( `subject option:value with space` )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option:value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option:value with space',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option:value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is not quoted and contains space'
    return null;
  })
  shell({ args : [ 'subject', 'option:value', 'with', 'space' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option:value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option:value with space',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option:value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is not quoted and contains space'
    return null;
  })
  shell({ args : [ 'subject', 'option', ':', 'value', 'with', 'space' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option', ':', 'value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option : value with space',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option : value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is quoted and contains space'
    return null;
  })
  shell( 'option:"value with space"' )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option:"value with space"' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option:"value with space"',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option:"value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is quoted and contains space'
    return null;
  })
  shell({ args : [ 'option', ':', '"value with space"' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option', ':', '"value with space"' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option : "value with space"',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is quoted and contains space'
    return null;
  })
  shell({ args : [ 'option', ':', 'value with space' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option', ':', 'value with space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option : "value with space"',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is not quoted and contains space'
    return null;
  })
  shell( 'option:value with space' )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option:value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option:value with space',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option:value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is not quoted and contains space'
    return null;
  })
  shell( 'option : value with space' )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option', ':', 'value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option : value with space',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option : value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.input should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is not quoted and contains space'
    return test.shouldThrowErrorOfAnyKind( () =>
    {
      return shell({ execPath : 'option:value with" space', ready : null })
    });
  })
  // .then( ( o ) =>
  // {
  //   test.identical( o.exitCode, 0 );
  //   var got = _.fileProvider.fileRead({ filePath, encoding : 'json' });
  //   var expected =
  //   {
  //     'scriptArgs' : [ 'option:value', 'with"', 'space' ],
  //     'interpreterArgsStrings' : '',
  //     'scriptArgsString' : 'option:value with" space',
  //     'subject' : '',
  //     'map' : { 'option' : 'value with" space' },
  //     'subjects' : [ '' ],
  //     'maps' : [ { 'option' : 'value with" space' } ],
  //     'original' : 'option:value with" space'
  //   }
  //   test.contains( got, expected );
  //   return null;
  // })
  /* qqq : ? */

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.input({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

// --
// path
// --

function realMainFile( test )
{
  let context = this;
  let a = test.assetFor( false );
  let testAppPath = a.program( testApp );
  let testAppPathNative = a.path.nativize( testAppPath );

  a.ready.then( () =>
  {
    test.case = 'compare with `testAppPath`'
    var o =
    {
      execPath :  'node ' + testAppPathNative,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( op.output.trim(), testAppPath );
      return null;
    })
  });

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );

    console.log( _.process.realMainFile() )
  }
};

//

function realMainDir( test )
{

  if( require.main === module )
  var file = __filename;
  else
  var file = require.main.filename;

  var expected1 = _.path.dir( file );

  test.case = 'compare with __filename path dir';
  var got = _.fileProvider.path.nativize( _.process.realMainDir( ) );
  test.identical( _.path.normalize( got ), _.path.normalize( expected1 ) );

  /* */

  test.case = 'absolute paths';
  var from = _.process.realMainDir();
  var to = _.process.realMainFile();
  var expected = _.path.name({ path : _.process.realMainFile(), full : 1 });
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  /* */

  test.case = 'absolute paths, from === to';
  var from = _.process.realMainDir();
  var to = _.process.realMainDir();
  var expected = '.';
  var got = _.path.relative( from, to );
  test.identical( got, expected );

}

//

function effectiveMainFile( test )
{
  if( require.main === module )
  var expected1 = __filename;
  else
  var expected1 = process.argv[ 1 ];

  test.case = 'compare with __filename path for main file';
  var got = _.path.nativize( _.process.effectiveMainFile() );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.process.effectiveMainFile( 'package.json' );
    });
  }
};

// --
// etc
// --

function pathsRead( test )
{
  test.case = 'arrayIs';
  var got = _.process.pathsRead();
  test.is( _.arrayIs( got ) );

  test.case = 'paths are normalized'
  got.forEach( ( path ) => test.is( _.path.isNormalized( path ) ) )

}

//

function systemEntryAddBasic( test )
{
  let context = this;
  let a = test.assetFor( 'systemEntry' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'basic';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/Index.js' ),
      allowingNotInPath : 1
    }
    var exp = 1;
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( a.abs( 'dir/Index.js' ) ) )
    test.is( _.objectIs( a.fileProvider.filesRead( a.abs( 'dir/Index.js' ) ) ) )

    return null;
  } );

  /* - */

  test.case = 'no arguments'
  test.shouldThrowErrorSync( () => _.process.systemEntryAdd() )
  test.case = 'extra arguments'
  test.shouldThrowErrorSync( () => _.process.systemEntryAdd( {}, 1 ) )
  test.case = 'o.entryDirPath is not provided'
  test.shouldThrowErrorSync( () => _.process.systemEntryAdd( a.abs( 'dir' ) ) )
  test.case = 'o.entryDirPath not in the PATH'
  test.shouldThrowErrorSync( () => _.process.systemEntryAdd({ appPath : a.abs( 'dir/file.txt' ), entryDirPath : a.abs( 'dir' ) }) )

  return a.ready;

}

//

function systemEntryAddOptionAllowingMissed( test )
{
  let context = this;
  let a = test.assetFor( 'systemEntry' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'not existing file';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/fileNotExists.js' ),
      allowingNotInPath : 1,
      allowingMissed : 1
    }
    var exp = 1;
    var expFilePath = process.platform === 'win32' ? a.abs( 'dir' ) + '/fileNotExists.bat' : a.abs( 'dir' ) + '/fileNotExists';
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( expFilePath ) )
    test.is( _.objectIs( a.fileProvider.filesRead( expFilePath ) ) )

    return null;
  } );

  return a.ready;
}

//

function systemEntryAddOptionAllowingNotInPath( test )
{
  let context = this;
  let a = test.assetFor( 'systemEntry' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'entryDirPath not in PATH, allowingNotInPath : 1';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/file.txt' ),
      allowingNotInPath : 1
    }
    var exp = 1;
    var expFilePath = process.platform === 'win32' ? a.abs( 'dir' ) + '/file.bat' : a.abs( 'dir' ) + '/file';
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( expFilePath ) )
    test.is( _.objectIs( a.fileProvider.filesRead( expFilePath ) ) )

    return null;
  } );

  return a.ready;
}

//

function systemEntryAddOptionForcing( test )
{
  let context = this;
  let a = test.assetFor( 'systemEntry' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'entryDirPath not in PATH, forcing : 1';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/file.txt' ),
      forcing : 1
    }
    var exp = 1;
    var expFilePath = process.platform === 'win32' ? a.abs( 'dir' ) + '/file.bat' : a.abs( 'dir' ) + '/file';
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( expFilePath ) )
    test.is( _.objectIs( a.fileProvider.filesRead( expFilePath ) ) )

    return null;
  } );

  a.ready.then( () =>
  {
    test.case = 'entryDirPath not in PATH, appPath doesn\'t exist, forcing : 1';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/fileNotExists.txt' ),
      forcing : 1
    }
    var exp = 1;
    var expFilePath = process.platform === 'win32' ? a.abs( 'dir' ) + '/fileNotExists.bat' : a.abs( 'dir' ) + '/fileNotExists';
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( expFilePath ) )
    test.is( _.objectIs( a.fileProvider.filesRead( expFilePath ) ) )

    return null;
  } );

  return a.ready;
}

//

var Proto =
{

  name : 'Tools.l3.process.Io',
  silencing : 1,
  routineTimeOut : 60000,
  onSuiteBegin : suiteBegin,
  onSuiteEnd : suiteEnd,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
    appJsPath : null,
  },

  tests :
  {

    // event

    processOnExitEvent,
    processOffExitEvent,

    // process args

    processArgsBase,
    processArgsPropertiesBase,
    processArgsMultipleCommands,
    processArgsPaths,
    processArgsWithSpace,

    // path

    realMainFile,
    realMainDir,
    effectiveMainFile,

    // etc

    pathsRead,

    // system entry

    systemEntryAddBasic,
    systemEntryAddOptionAllowingMissed,
    systemEntryAddOptionAllowingNotInPath,
    systemEntryAddOptionForcing,

  }

}

_.mapExtend( Self, Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
