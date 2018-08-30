/**
 * Copyright 2018 Marc René Schädler
 *
 * This file is part of the mobile hearing aid prototype project
 * The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.
 */

void
feedback(float const * const in1,
         float const * const in2,
         float * const out,
         float * const playbackbuffer,
         float const * const feedbackresponse,
         int const * const range
        )
{ 
  int feedbacksamples = FEEDBACKLENGTH*TICKSAMPLES;
  // Calculate feedback from playback
  {
    for (int i=0;i<TICKSAMPLES;i++) {
      float feedback_tmp = 0.0;

      // Determine integration ranges
      {
        // Range in feedback
        int start1 = range[0];
        int stop1 = range[1];
        // Cursor in playbackbuffer
        int o1 = tickcount*TICKSAMPLES;
        // Range in playbackbuffer
        int start2 = (feedbacksamples+o1+i-start1)%feedbacksamples;
        int stop2 = (feedbacksamples+o1+i-stop1)%feedbacksamples;
        int o2 = start1;
        if (stop2 < start2) {
          for (int j=start2;j>stop2;j--) {
            feedback_tmp += playbackbuffer[j] * feedbackresponse[o2];
            o2++;
          }
        } else {
          for (int j=start2;j>=0;j--) {
            feedback_tmp += playbackbuffer[j] * feedbackresponse[o2];
            o2++;
          }
          for (int j=feedbacksamples-1;j>stop2;j--) {
            feedback_tmp += playbackbuffer[j] * feedbackresponse[o2];
            o2++;
          }
        }
      }
      // Remove estimated feedback signal from recording
      out[i] = in1[i] - feedback_tmp;
    }
  }

  // Copy new samples to the playbackbuffer
  {
    int o1 = tickcount*TICKSAMPLES;
    for (int i=0;i<TICKSAMPLES;i++) {
      playbackbuffer[o1] = in2[i];
      o1++;
    }
  }
}
