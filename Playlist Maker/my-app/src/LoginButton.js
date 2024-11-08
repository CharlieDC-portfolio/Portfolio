import React from 'react';
import './LoginButton.css'
import 'reactjs-popup/dist/index.css';
import profile from './profile-default.svg';


const SPACE_DELIM = "%20";

const CLIENT_ID = "bd84d93076144a869d1990b8aa228cb9";
const SPOTIFY_AUTHORISE_ENDPOINT = 'https://accounts.spotify.com/authorize';
const REDIRECT_URL_AFTER_LOGIN = "http://localhost:3000/Callback";

const SCOPES = ["playlist-modify-public", "playlist-modify-private", "playlist-read-private", "user-read-private", "user-read-email"];
const SCOPES_URL_PARAM = SCOPES.join(SPACE_DELIM);



const handleLogin = () => {
    window.location = `${SPOTIFY_AUTHORISE_ENDPOINT}?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URL_AFTER_LOGIN}&scope=${SCOPES_URL_PARAM}&response_type=token&show_dialogue=true`;
};

const LoginButton = () => (
  <button class="button" onClick={handleLogin}><img src={profile} className="defualt-profile" alt="profile" /></button>
);




export default LoginButton
