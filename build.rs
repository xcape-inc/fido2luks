#![allow(warnings)]
#[macro_use]
extern crate failure;
extern crate ctap_hmac as ctap;

#[path = "src/cli_args/mod.rs"]
mod cli_args;
#[path = "src/error.rs"]
mod error;
#[path = "src/util.rs"]
mod util;

use cli_args::Args;
use std::env;
use std::str::FromStr;
use structopt::clap::Shell;
use structopt::StructOpt;

// neat trick from https://github.com/mmstick/cargo-deb/blob/e43018a46b8dc922cfdf6cdde12f7ed92fcc41aa/example/build.rs
// to get around poisoning the source dirt during packaging
use std::path::PathBuf;
use std::fs;

fn main() {
    // get the out_dir consistent base path (the target dir) and append assets directory
    let out_str = env::var("OUT_DIR").unwrap();
    let outdir = PathBuf::from(&out_str);
    let mut outdir = outdir
        .ancestors()  // .../target/<debug|release>/build/example-<SHA>/out
        .skip(3)      // .../target/<debug|release>
        .next().unwrap().to_owned();
        outdir.push("assets");

    // create the assets directory if it does not already exist
    if !outdir.exists() {
        fs::create_dir(&outdir).expect("Could not create assets dir");
    }

    // generate completion scripts, zsh does panic for some reason
    for shell in Shell::variants().iter().filter(|shell| **shell != "zsh") {
        Args::clap().gen_completions(env!("CARGO_PKG_NAME"), Shell::from_str(shell).unwrap(), &outdir);
    }
}
