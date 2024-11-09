import React, { useEffect } from "react";
import logo from './spotify-icon.svg';
import './App.css';
import LogOutButton from './LogOutButton';
import GeneratePlaylistButton from "./GeneratePlaylistButton";



  const getReturnedParamsFromSpotifyAuth = (hash) => {
    const stringAfterHashtag = hash.substring(1);
    const paramsInUrl = stringAfterHashtag.split("&");
    const paramsSplitUp = paramsInUrl.reduce((accumulater, currentValue) => {
      console.log(currentValue);
      const [key, value] = currentValue.split("=");
      accumulater[key] = value;
      return accumulater;
    }, {});
  
    return paramsSplitUp;
  };
  
  const Callback = () => {
    useEffect(() => {
      if (window.location.hash) {
        const { access_token, expires_in, token_type } =
          getReturnedParamsFromSpotifyAuth(window.location.hash);
  
        localStorage.clear();
  
        localStorage.setItem("accessToken", access_token);
        localStorage.setItem("tokenType", token_type);
        localStorage.setItem("expiresIn", expires_in);
      }
    });

  return (
    <div className="App">
      <LogOutButton />
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <a>
          <GeneratePlaylistButton />
        </a>
      </header>
    </div>
  );
};


export default Callback;